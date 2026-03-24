import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';

class AiChatService {
  final Dio _dio = Dio();
  final List<Map<String, dynamic>> _geminiHistory = [];
  String _shopData = '';
  String _courtsData = '';
  String _servicesData = '';
  bool _useGemini = false;
  String _apiKey = '';
  String _modelName = '';
  Future<void>? _modelReady;

  static const _fallbackKey = 'AIzaSyB9EuAwBsU6IYIMqZVSrgSUryyTTiwapjk';

  AiChatService() {
    _apiKey = ApiConstants.geminiApiKey.isNotEmpty
        ? ApiConstants.geminiApiKey
        : _fallbackKey;
    _useGemini = _apiKey.isNotEmpty;
    debugPrint('[AI Chat] Mode: ${_useGemini ? "Gemini API" : "Offline"}');
    if (_useGemini) _modelReady = _findModel();
  }

  /// Tự động tìm model generateContent khả dụng
  Future<void> _findModel() async {
    try {
      final resp = await _dio.get(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey',
      );
      final models = resp.data['models'] as List? ?? [];
      debugPrint('[AI Chat] Found ${models.length} models');

      // Ưu tiên: flash > pro, 2.0 > 1.5
      final preferred = [
        'gemini-2.5-flash',
        'gemini-2.5-flash-lite',
        'gemini-2.5-pro',
        'gemini-2.0-flash-001',
        'gemini-2.0-flash-lite',
        'gemini-flash-latest',
        'gemini-pro-latest',
      ];

      for (final m in models) {
        final name = m['name']?.toString() ?? '';
        final methods = (m['supportedGenerationMethods'] as List?)?.cast<String>() ?? [];
        final shortName = name.replaceFirst('models/', '');
        if (methods.contains('generateContent')) {
          debugPrint('[AI Chat] Model: $shortName (supports generateContent)');
        }
      }

      // Tìm model ưu tiên
      for (final pref in preferred) {
        for (final m in models) {
          final name = (m['name']?.toString() ?? '').replaceFirst('models/', '');
          final methods = (m['supportedGenerationMethods'] as List?)?.cast<String>() ?? [];
          if (name == pref && methods.contains('generateContent')) {
            _modelName = name;
            debugPrint('[AI Chat] Selected model: $_modelName');
            return;
          }
        }
      }

      // Fallback: dùng bất kỳ model nào support generateContent
      for (final m in models) {
        final name = (m['name']?.toString() ?? '').replaceFirst('models/', '');
        final methods = (m['supportedGenerationMethods'] as List?)?.cast<String>() ?? [];
        if (methods.contains('generateContent') && name.contains('gemini')) {
          _modelName = name;
          debugPrint('[AI Chat] Fallback model: $_modelName');
          return;
        }
      }

      debugPrint('[AI Chat] No suitable model found, disabling Gemini');
      _useGemini = false;
    } catch (e) {
      debugPrint('[AI Chat] List models error: $e');
      _useGemini = false;
    }
  }

  // ───────────────────── Context ─────────────────────

  void updateSystemInstruction({
    required String shopData,
    required String courtsData,
    required String servicesData,
  }) {
    _shopData = shopData;
    _courtsData = courtsData;
    _servicesData = servicesData;

    if (_useGemini) {
      _geminiHistory.clear();
      final instruction = '''
Bạn là trợ lý AI cho cửa hàng cầu lông. Dưới đây là thông tin thực tế từ hệ thống:

THÔNG TIN CỬA HÀNG:
$shopData

DANH SÁCH SÂN:
$courtsData

DỊCH VỤ ĐI KÈM:
$servicesData

NHIỆM VỤ:
1. Trả lời dựa trên thông tin trên. Nếu không có thông tin, hãy nói bạn không rõ và khuyên người dùng liên hệ hotline.
2. Luôn thân thiện, chuyên nghiệp và ngắn gọn.
3. Chỉ trả lời bằng tiếng Việt.
''';
      _geminiHistory.add({
        'role': 'user',
        'parts': [{'text': 'Hệ thống: $instruction'}]
      });
      _geminiHistory.add({
        'role': 'model',
        'parts': [{'text': 'Đã hiểu. Tôi sẽ hỗ trợ bạn theo thông tin hệ thống.'}]
      });
    }
    debugPrint('[AI Chat] Context updated');
  }

  // ───────────────────── Public API ─────────────────────

  Future<String?> sendMessage(String message) async {
    if (_useGemini) {
      // Đợi tìm model xong trước khi gửi
      if (_modelReady != null) await _modelReady;
      final result = await _sendGemini(message);
      if (result != null) return result;
      debugPrint('[AI Chat] Gemini failed → fallback offline');
    }
    return _sendOffline(message);
  }

  void resetChat() {
    _geminiHistory.clear();
  }

  // ───────────────────── Gemini (REST v1) ─────────────────────

  Future<String?> _sendGemini(String message) async {
    try {
      debugPrint('[AI Chat] Gemini → $message');
      _geminiHistory.add({
        'role': 'user',
        'parts': [{'text': message}]
      });

      if (_modelName.isEmpty) {
        debugPrint('[AI Chat] No model available yet');
        _geminiHistory.removeLast();
        return null;
      }

      final resp = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent?key=$_apiKey',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
        ),
        data: {
          'contents': _geminiHistory,
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          },
        },
      );

      final text = resp.data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
      if (text != null) {
        _geminiHistory.add({
          'role': 'model',
          'parts': [{'text': text}]
        });
        debugPrint('[AI Chat] Gemini OK');
        return text;
      }
      _geminiHistory.removeLast();
      return null;
    } on DioException catch (e) {
      debugPrint('[AI Chat] Gemini error: ${e.response?.statusCode}');
      debugPrint('[AI Chat] Response body: ${e.response?.data}');
      debugPrint('[AI Chat] API key used: ${_apiKey.substring(0, 10)}...');
      if (_geminiHistory.isNotEmpty) _geminiHistory.removeLast();
      return null;
    } catch (e) {
      debugPrint('[AI Chat] Gemini error: $e');
      if (_geminiHistory.isNotEmpty) _geminiHistory.removeLast();
      return null;
    }
  }

  // ───────────────────── Offline ─────────────────────

  int _score(String msg, List<String> keys) =>
      keys.where((k) => msg.contains(k)).length;

  Future<String?> _sendOffline(String message) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final msg = message.toLowerCase().trim();

    // Tính điểm cho tất cả topic, chọn topic có điểm cao nhất
    final scores = <String, int>{
      'greeting': _score(msg, ['xin chào', 'hello', 'hi', 'chào', 'hey', 'alo']),
      'couple': _score(msg, ['bạn gái', 'người yêu', 'cặp đôi', 'hẹn hò', 'date', 'rủ đi đánh']),
      'group': _score(msg, ['nhóm', 'team', 'bạn bè', 'đông người', 'mấy người', 'đánh đôi']),
      'newbie': _score(msg, ['mới chơi', 'mới tập', 'newbie', 'chưa biết', 'bắt đầu', 'mới học']),
      'shop': _score(msg, ['cửa hàng', 'shop', 'địa chỉ', 'ở đâu', 'liên hệ', 'hotline']),
      'court': _score(msg, ['danh sách sân', 'loại sân', 'sân nào', 'bao nhiêu sân', 'court']),
      'price': _score(msg, ['giá', 'bao nhiêu tiền', 'chi phí', 'phí', 'price', 'cost', 'rẻ', 'đắt']),
      'service': _score(msg, ['dịch vụ', 'service', 'cho thuê', 'thuê vợt', 'mua cầu', 'khăn']),
      'hours': _score(msg, ['mở cửa', 'đóng cửa', 'mấy giờ', 'giờ hoạt động', 'giờ mở', 'khi nào mở']),
      'booking': _score(msg, ['đặt sân', 'đặt lịch', 'book', 'booking', 'cách đặt', 'hướng dẫn đặt']),
      'payment': _score(msg, ['thanh toán', 'payment', 'trả tiền', 'vnpay', 'chuyển khoản']),
      'cancel': _score(msg, ['hủy', 'cancel', 'đổi lịch', 'dời', 'hoàn tiền']),
      'promo': _score(msg, ['khuyến mãi', 'giảm giá', 'ưu đãi', 'voucher', 'sale', 'promo']),
      'account': _score(msg, ['tài khoản', 'đăng ký', 'đăng nhập', 'login', 'quên mật khẩu']),
      'weather': _score(msg, ['mưa', 'nắng', 'thời tiết', 'weather']),
      'parking': _score(msg, ['đỗ xe', 'gửi xe', 'parking', 'bãi xe', 'xe máy', 'ô tô']),
      'food': _score(msg, ['đồ ăn', 'uống', 'cafe', 'quán ăn', 'đói']),
      'outfit': _score(msg, ['mặc gì', 'mang gì', 'chuẩn bị gì', 'trang phục', 'giày']),
      'rules': _score(msg, ['luật', 'quy tắc', 'rules', 'cách chơi', 'tính điểm']),
      'health': _score(msg, ['sức khỏe', 'giảm cân', 'giảm mỡ', 'cardio', 'calories']),
      'facility': _score(msg, ['wifi', 'wc', 'nhà vệ sinh', 'phòng thay đồ', 'tắm', 'locker']),
      'event': _score(msg, ['sinh nhật', 'team building', 'sự kiện', 'event', 'tổ chức']),
      'family': _score(msg, ['trẻ em', 'con nhỏ', 'gia đình', 'bé', 'kids', 'family']),
      'coach': _score(msg, ['hlv', 'huấn luyện', 'coach', 'dạy chơi', 'khóa học', 'học chơi']),
      'compare': _score(msg, ['khác nhau', 'so sánh', 'vip', 'tiêu chuẩn hay vip', 'nên chọn sân']),
      'injury': _score(msg, ['chấn thương', 'đau', 'bong gân', 'chuột rút', 'nhức']),
      'racket': _score(msg, ['mua vợt', 'vợt nào', 'tư vấn vợt', 'yonex', 'lining', 'victor']),
      'summer': _score(msg, ['nóng', 'mùa hè', 'summer']),
      'thanks': _score(msg, ['cảm ơn', 'thanks', 'thank you']),
      'bye': _score(msg, ['bye', 'tạm biệt', 'bái', 'see you', 'hẹn gặp']),
    };

    // Thêm bonus cho keyword đặc biệt (ưu tiên giờ hơn sân)
    if (msg.contains('mấy giờ') || msg.contains('giờ nào') || msg.contains('mở cửa')) {
      scores['hours'] = (scores['hours'] ?? 0) + 3;
    }
    if (msg.contains('đặt sân') || msg.contains('cách đặt')) {
      scores['booking'] = (scores['booking'] ?? 0) + 3;
    }

    // Tìm topic có điểm cao nhất
    String bestTopic = 'default';
    int bestScore = 0;
    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestTopic = entry.key;
      }
    }

    return _getResponse(bestTopic);
  }

  String _getResponse(String topic) {
    switch (topic) {
      case 'greeting':
        return 'Xin chào! Tôi là trợ lý AI của hệ thống đặt sân cầu lông.\n\n'
            'Bạn có thể hỏi tôi về:\n'
            '• Thông tin cửa hàng, địa chỉ\n'
            '• Danh sách sân và bảng giá\n'
            '• Dịch vụ cho thuê vợt, mua cầu\n'
            '• Giờ hoạt động\n'
            '• Hướng dẫn đặt sân\n'
            '• Gợi ý combo cho cặp đôi, nhóm bạn\n\n'
            'Hãy đặt câu hỏi cho tôi nhé!';

      case 'couple':
        return 'Rủ bạn gái đi đánh cầu lông là ý tưởng tuyệt vời!\n\n'
            'Gợi ý combo cho 2 người:\n'
            '• Đặt 1 sân tiêu chuẩn (120.000đ/giờ)\n'
            '• Thuê 2 vợt (30.000đ x 2 = 60.000đ)\n'
            '• Mua 1 hộp cầu (50.000đ)\n'
            '• 2 chai nước (15.000đ x 2 = 30.000đ)\n\n'
            'Tổng: khoảng 260.000đ cho 1 giờ!\n'
            'Nên đặt khung giờ 17:00-19:00 chiều, trời mát lãng mạn.';

      case 'group':
        return 'Đi đánh cầu lông nhóm bạn thì siêu vui!\n\n'
            'Gợi ý cho nhóm 4-6 người:\n'
            '• Đặt 1-2 sân (120.000đ - 180.000đ/giờ/sân)\n'
            '• Thuê vợt nếu thiếu (30.000đ/cây)\n'
            '• Mua 2-3 hộp cầu (50.000đ/hộp)\n\n'
            'Chia ra mỗi người chỉ 50.000đ - 80.000đ!\n'
            'Nên đặt sân sớm vào cuối tuần vì hay hết chỗ!';

      case 'newbie':
        return 'Chào mừng bạn đến với cầu lông!\n\n'
            '• Thuê vợt tại sân (30.000đ/cây)\n'
            '• Mang giày thể thao đế cao su\n'
            '• Khởi động kỹ 10-15 phút\n'
            '• Nên đặt khung giờ vắng (9:00-11:00 sáng)\n'
            '• Chơi 1 tiếng đầu là đủ!';

      case 'shop':
        return _shopData.isNotEmpty
            ? 'Thông tin cửa hàng:\n$_shopData\n\nĐến trực tiếp hoặc đặt sân online qua app!'
            : 'Tên: Hệ thống VNB Sports\nĐịa chỉ: TP. Hồ Chí Minh\nHotline: 1900 1234';

      case 'court':
        return _courtsData.isNotEmpty
            ? 'Danh sách sân:\n$_courtsData\n\nVào "Đặt sân" để xem lịch trống!'
            : 'Các loại sân:\n• Sân tiêu chuẩn: 120.000đ/giờ\n• Sân VIP: 180.000đ/giờ';

      case 'price':
        final buf = StringBuffer('Bảng giá tham khảo:\n\n');
        if (_courtsData.isNotEmpty) buf.writeln('SÂN:\n$_courtsData\n');
        if (_servicesData.isNotEmpty) buf.writeln('DỊCH VỤ:\n$_servicesData\n');
        if (_courtsData.isEmpty && _servicesData.isEmpty) {
          buf.writeln('• Sân tiêu chuẩn: 120.000đ/giờ\n• Sân VIP: 180.000đ/giờ');
          buf.writeln('• Thuê vợt: 30.000đ/cây\n• Cầu: 50.000đ/hộp\n• Nước: 15.000đ/chai');
        }
        buf.write('Giờ cao điểm (17:00-21:00) có thể tăng giá.');
        return buf.toString();

      case 'service':
        return _servicesData.isNotEmpty
            ? 'Dịch vụ đi kèm:\n$_servicesData\n\nĐặt thêm khi book sân hoặc mua tại quầy!'
            : 'Dịch vụ tại sân:\n• Cho thuê vợt: 30.000đ/cây\n• Cầu lông: 50.000đ/hộp\n• Nước: 15.000đ/chai\n• Khăn tập: 20.000đ/cái';

      case 'hours':
        return 'Giờ hoạt động:\n'
            '• Thứ 2 - Thứ 6: 6:00 - 22:00\n'
            '• Thứ 7 - Chủ nhật: 6:00 - 23:00\n'
            '• Lễ Tết: 7:00 - 22:00\n\n'
            'Khung giờ đông: 17:00 - 21:00\n'
            'Khung giờ vắng, giá tốt: 6:00 - 11:00 sáng';

      case 'booking':
        return 'Hướng dẫn đặt sân:\n\n'
            '1. Mở app → "Đặt sân"\n'
            '2. Chọn sân (tiêu chuẩn/VIP)\n'
            '3. Chọn ngày chơi\n'
            '4. Chọn khung giờ trống\n'
            '5. Thêm dịch vụ nếu cần\n'
            '6. Xác nhận và thanh toán qua VNPay\n'
            '7. Nhận thông báo xác nhận!';

      case 'payment':
        return 'Phương thức thanh toán:\n\n'
            '• VNPay: quét QR hoặc nhập thẻ ATM/Visa\n'
            '• Tại quầy: tiền mặt hoặc chuyển khoản';

      case 'cancel':
        return 'Chính sách hủy/đổi sân:\n\n'
            '• Hủy trước 24h: hoàn 100%\n'
            '• Hủy trước 2h: hoàn 50%\n'
            '• Hủy dưới 2h: không hoàn tiền';

      case 'promo':
        return 'Ưu đãi hiện tại:\n\n'
            '• Buổi sáng (6:00-11:00): giảm 10%\n'
            '• Combo 5 buổi: tặng 1 buổi free\n'
            '• Thành viên mới: giảm 20% lần đầu\n'
            '• Giới thiệu bạn bè: cả 2 giảm 15%';

      case 'account':
        return 'Hướng dẫn tài khoản:\n\n'
            '• Đăng ký: Bấm "Đăng ký" → nhập email + mật khẩu\n'
            '• Đăng nhập: Email + mật khẩu hoặc Google\n'
            '• Quên mật khẩu: "Quên mật khẩu" → nhập email';

      case 'weather':
        return 'Sân trong nhà nên mưa hay nắng đều chơi được!\nCó mái che, quạt/điều hòa. Không lo thời tiết!';

      case 'parking':
        return 'Gửi xe:\n• Xe máy: miễn phí khi đặt sân\n• Ô tô: 10.000đ/lượt\n• Bảo vệ trông xe 24/7';

      case 'food':
        return 'Tại sân có:\n• Quầy nước: nước suối, trà đá, café\n• Snack bar: bánh mì, xôi\n• Giá: 10.000đ - 25.000đ';

      case 'outfit':
        return 'Cần chuẩn bị:\n• Giày thể thao đế cao su (quan trọng!)\n• Quần áo thể thao\n• Khăn mồ hôi, bình nước\n\nKhông cần vợt/cầu - thuê tại sân được!';

      case 'rules':
        return 'Luật cầu lông cơ bản:\n• Đánh đơn: sân hẹp | Đánh đôi: sân rộng\n• 3 set, mỗi set 21 điểm\n• Thắng cách 2 điểm (tối đa 30)\n\nChơi vui thì thoải mái!';

      case 'health':
        return 'Lợi ích cầu lông:\n• Đốt 400-600 calories/giờ\n• Tăng phản xạ và linh hoạt\n• Tốt cho tim mạch\n• Giảm stress\n\nChơi 2-3 buổi/tuần là lý tưởng!';

      case 'facility':
        return 'Tiện ích:\n• Wifi miễn phí\n• WC sạch sẽ\n• Phòng thay đồ nam/nữ\n• Phòng tắm nước nóng\n• Tủ locker miễn phí';

      case 'event':
        return 'Tổ chức sự kiện:\n• Team building: 2-4 sân, thi đấu mini\n• Sinh nhật: sân + bánh/nước\n• Đặt từ 3 sân: giảm 15%\n\nLiên hệ hotline để tư vấn!';

      case 'family':
        return 'Cầu lông cho gia đình:\n• Trẻ từ 6 tuổi chơi được\n• Vợt size nhỏ: thuê 20.000đ\n• Khung giờ sáng 8:00-11:00 lý tưởng\n• Cho bé chơi 30-45 phút\n\nGắn kết gia đình tuyệt vời!';

      case 'coach':
        return 'Dịch vụ huấn luyện:\n• HLV cá nhân: 200.000đ/buổi\n• Lớp nhóm: 80.000đ/người/buổi\n• Khóa cơ bản 8 buổi: 1.200.000đ\n\nLiên hệ hotline để đăng ký!';

      case 'compare':
        return 'So sánh sân:\n\nTIÊU CHUẨN (120K/h): Sân PVC, đèn tiêu chuẩn, quạt\nVIP (180K/h): Sân gỗ, đèn LED, điều hòa\n\nChơi vui → tiêu chuẩn. Trải nghiệm tốt → VIP!';

      case 'injury':
        return 'Phòng chấn thương:\n• Khởi động kỹ 10-15 phút\n• Mang giày đế cao su\n• Uống nước đều\n• Nghỉ khi mệt\n\nBị đau → nghỉ + chườm đá!';

      case 'racket':
        return 'Tư vấn vợt:\n• Người mới (<500K): Yonex GR 303\n• Trung cấp (500K-1.5M): Yonex Astrox 1DG\n• Nâng cao (>1.5M): Yonex Astrox 88D\n\nChưa chắc? Thuê vợt thử trước!';

      case 'summer':
        return 'Mùa hè:\n• Sân trong nhà, quạt/điều hòa mát\n• Nên chơi sáng hoặc tối\n• Mang đủ nước, đồ thoáng mát\n\nSân VIP có điều hòa, chơi giữa trưa cũng ok!';

      case 'thanks':
        return 'Không có gì! Chúc bạn có buổi chơi cầu lông vui vẻ! Cần gì thêm cứ nhắn nhé!';

      case 'bye':
        return 'Tạm biệt! Hẹn gặp lại trên sân cầu lông nhé!';

      default:
        return 'Tôi có thể hỗ trợ bạn về:\n\n'
            '• "Giá sân" - Xem bảng giá\n'
            '• "Danh sách sân" - Xem sân trống\n'
            '• "Cách đặt sân" - Hướng dẫn\n'
            '• "Giờ mở cửa" - Giờ hoạt động\n'
            '• "Rủ bạn gái đi đánh" - Combo cặp đôi\n'
            '• "Mới tập chơi" - Tips người mới\n'
            '• "Tư vấn vợt" - Chọn vợt\n\n'
            'Hãy hỏi cụ thể hơn nhé!';
    }
  }

}

