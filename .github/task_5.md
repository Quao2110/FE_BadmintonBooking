# 📱 Flutter Task: Customer - Cart, Order & Inbox

**Người thực hiện:** Hùng  
**Vai trò:** Frontend Developer (Flutter)  
**Phối hợp cùng:** BE 5 (Payment) & BE 6 (Messaging)

---

## 📋 Danh sách Task (Checklist)

- [ ] **Task 4.1:** UI/UX Giỏ hàng (Cart Screen)
- [ ] **Task 4.2:** Checkout Flow & Tích hợp VNPAY
- [ ] **Task 4.3:** Lịch sử cá nhân (Đơn hàng & Đặt sân)
- [ ] **Task 4.4:** UI Hộp thư hỗ trợ (Customer Support)

---

## 🛠 Chi tiết Kỹ thuật Flutter

### 🔹 Task 4.1: Cart Screen (Quản lý giỏ hàng)

Xây dựng giao diện danh sách sản phẩm người dùng đã chọn.

- **Tính năng:**
  - Hiển thị List Card (Ảnh, Tên SP, Giá, Phân loại).
  - Widget tăng/giảm số lượng ($+$ / $-$) kèm Debounce để tránh gọi API quá nhiều lần.
  - Tính toán **Subtotal** (Tạm tính) và **Total** ngay trên UI.
  - Swipe to Dismiss: Vuốt để xóa nhanh sản phẩm khỏi giỏ.
- **State Management:** Sử dụng Provider/Bloc để quản lý trạng thái giỏ hàng toàn cục.

---

### 🔹 Task 4.2: Checkout & Payment Flow

Giao diện hoàn tất đơn hàng và kết nối cổng thanh toán.

- **Form thông tin:** Địa chỉ giao hàng, Số điện thoại, Ghi chú.
- **Phương thức thanh toán:** Radio Button chọn "COD" hoặc "VNPAY/MoMo".
- **Logic VNPAY:** \* Khi nhấn "Thanh toán", gọi API Checkout của BE để nhận `paymentUrl`.
  - Sử dụng Package `webview_flutter` hoặc `url_launcher` để mở Link thanh toán.
  - Lắng nghe URL Redirect từ VNPAY để thông báo "Thanh toán thành công/thất bại" cho User.

---

### 🔹 Task 4.3: Order History (Lịch sử cá nhân)

Thiết kế trang quản lý các giao dịch đã thực hiện.

- **UI:** Sử dụng `TabBar` với 2 Tab chính:
  1.  **Mua hàng:** Danh sách đơn hàng vật lý (Sản phẩm, Trạng thái: Chờ duyệt, Đang giao...).
  2.  **Đặt sân:** Danh sách lịch đặt sân (Ngày giờ, Số sân, Trạng thái thanh toán).
- **Feature:** Pull-to-refresh để cập nhật trạng thái mới nhất từ server.

---

### 🔹 Task 4.4: Inbox/Support UI

Giao diện nhắn tin hỗ trợ dành cho khách hàng (Kết nối với BE 6).

- **Danh sách tin nhắn:** Hiển thị dạng bong bóng chat (Bubble chat). Phân biệt màu sắc giữa Khách và Admin.
- **Cơ chế tải:** \* Không yêu cầu Realtime (Socket).
  - Thiết kế nút **Reload** (IconButton) hoặc vuốt xuống để fetch tin nhắn mới.
- **Input:** TextField gửi tin nhắn văn bản đơn giản.

---

## 🔗 Liên kết dữ liệu (Integration)

| Task FE | API Endpoint tương ứng (BE 5 & 6)                      |
| :------ | :----------------------------------------------------- |
| **4.1** | `GET /cart`, `PUT /cart/update`, `DELETE /cart/remove` |
| **4.2** | `POST /order/checkout` (Nhận Link VNPAY)               |
| **4.3** | `GET /orders/me`, `GET /bookings/me`                   |
| **4.4** | `GET /messages`, `POST /messages/send`                 |

---

## ⚠️ Lưu ý cho Flutter

1. **Error Handling:** Phải có màn hình hoặc Toast thông báo khi số lượng sản phẩm trong kho không đủ (Response từ BE Task 5.2).
2. **WebView:** Kiểm tra kỹ cấu hình `InAppWebView` trên cả iOS và Android để đảm bảo Link thanh toán không bị chặn.
3. **Empty State:** Thiết kế UI khi giỏ hàng trống hoặc chưa có lịch sử đơn hàng.
