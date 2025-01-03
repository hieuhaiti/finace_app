# Finance App

## Mô tả
Ứng dụng Flutter quản lý tài chính cá nhân, giúp người dùng:
- Theo dõi chi tiêu.
- Lên kế hoạch tài chính.
- Đạt được mục tiêu tiết kiệm.

**Tác giả:**
2121051127 - Hà Trung Hiếu - HUMG

---

## Cài đặt

### 1. Cài đặt thư viện cho Backend
```bash
cd back_end
flutter pub get
```
### 2. Cài đặt thư viện cho Frontend
```bash
cd front_end
flutter pub get
```
## Chức năng
### 1. Server

#### General Routes
- GET / <br>
Trả về thông tin cơ bản của API<br>
#### User Routes
- POST /api/v1/users/signup<br>
Đăng ký người dùng mới.<br>
- POST /api/v1/users/signin<br>
Đăng nhập người dùng.<br>
- GET /api/v1/users/userId<br>
Lấy thông tin người dùng theo ID.<br>
- GET /api/v1/users/username/username<br>
Lấy thông tin người dùng theo tên đăng nhập.<br>
- PUT /api/v1/users/userId<br>
Cập nhật thông tin người dùng.<br>
- DELETE /api/v1/users/userId<br>
Xóa người dùng.<br>
#### Transaction Routes
- GET /api/v1/transactions/userId<br>
Lấy tất cả giao dịch của người dùng.<br>
- GET /api/v1/transaction/transactionId<br>
Lấy thông tin giao dịch cụ thể theo ID.<br>
- POST /api/v1/transaction<br>
Tạo mới giao dịch.<br>
- PUT /api/v1/transaction/transactionId<br>
Cập nhật giao dịch.<br>
- DELETE /api/v1/transaction/transactionId<br>
Xóa giao dịch.<br>
- GET /api/v1/transactions/userId/aggregate/key<br>
Tổng hợp giao dịch theo một tiêu chí (vd: loại giao dịch).<br>
- GET /api/v1/transactions/userId/aggregate/key/month/year<br>
Tổng hợp giao dịch theo tháng<br>ăm.<br>

#### Spending Plan Routes
- GET /api/v1/spending-plans/userId<br>
Lấy tất cả kế hoạch chi tiêu của người dùng.<br>
- POST /api/v1/spending-plans/userId<br>
Tạo hoặc cập nhật kế hoạch chi tiêu.<br>
- DELETE /api/v1/spending-plans/userId/spentPlan<br>
Xóa kế hoạch chi tiêu.<br>
#### Dashboard Routes
- GET /api/v1/dashBoard/userId<br>etworth/current<br>
Lấy giá trị tài sản ròng hiện tại.<br>
- GET /api/v1/dashBoard/userId<br>etworth/detail<br>
Lấy chi tiết tài sản ròng.<br>
- GET /api/v1/dashBoard/userId/category/current/numberOfCategory<br>
Lấy danh mục chi tiêu hiện tại.<br>
- GET /api/v1/dashBoard/userId/category/detail<br>
Lấy chi tiết danh mục chi tiêu.<br>
- GET /api/v1/dashBoard/userId/spending-plant/current<br>
Lấy thông tin kế hoạch chi tiêu hiện tại.<br>
- GET /api/v1/dashBoard/userId/spending-plant/detail/spentPlan<br>
Lấy chi tiết kế hoạch chi tiêu.<br>
#### Spending Plan Details
- GET /api/v1/spending-plans/userId/spentPlan/type<br>
Lấy chi tiết kế hoạch chi tiêu theo loại.<br>
### 2. Client
#### User
- ##### sign in
<br>![alt text](sign_in.png)<br>
- ##### sign up
<br>![alt text](sign_up.png)<br>
#### Dash board Tab
<br>![alt text](dash_board.png)<br>
- ##### Total Budget
dùng để theo dõi tổng kết tỉ lệ outcome / income trong tháng
 <br>![alt text](total_budget.png)<br>
- ##### Spending Plan
dùng để theo dõi tổng kết số dư của plan và tỉ lệ outcome / income trong tháng
<br>![alt text](spending_plan.png)<br>
- ##### Category Board
hiện thị top category chi tiêu
<br>![alt text](category_board.png)<br>
#### Spending Plan Tab
<br>![alt text](spending_plan_tab.png)<br>
- ##### Spending Plan Card
các card có thể trượt sang để xem các plan chi tiêu khác
theo dõi tổng số dư và tỉ lệ outcome / income trong tháng
<br>![alt text](spending_plan_card.png)<br>
<br>![alt text](spending_plan_card1.png)<br>
<br>![alt text](spending_plan_card2.png)<br>
khi ấn hiện thị tỉ lệ giữa các plan
<br>![alt text](spending_modal.png)<br>
- ##### Spending Plan Chart
các biểu đồ có thể trượt sang để xem các option filter chi tiêu khác
theo dõi tỉ lệ tăng giảm giữa các tháng
<br>![alt text](spending_plan_chart.png)<br>
<br>![alt text](spending_plan_chart1.png)<br>
<br>![alt text](spending_plan_chart2.png)<br>
*Chức năng cho phép người dùng có thể lọc biểu đồ theo tháng đang được phát triển.*
- ##### Spending Plan Detail
<br>![alt text](spending_plan_detail.png)<br>
*Chức năng cho phép người dùng có thể lọc các giao dịch theo khoảng thời gian đang được phát triển*
#### Category Tab
<br>![alt text](category_tab.png)<br>
- ##### Category Chart
hiện thị biểu đồ top 4 các category được chi tiêu nhiều nhất trong tháng
<br>![alt text](category_chart.png)<br>
*Chức năng cho phép người dùng có thể lọc biểu đồ theo top category thay vì 4 category cố định đang được phát triển.*
- ##### Category Detail
hiện thị các category được chi tiêu từ cao đến thấp trong tháng
<br>![alt text](category_detail.png)<br>
*Chức năng cho phép người dùng có thể các giao dịch theo category được nhấn vào đang được phát triển.*
#### User Tab
<br>![alt text](user_tab.png)<br>
chức năng chính để người dùng đổi mật khẩu

#### Chức năng thêm giao dịch
<br>![alt text](add_transaction.png)<br>
*Chức năng cho phép người dùng có thể chuyển nguồn tiền từ các plan đang được phát triển.*

#### Chức năng sửa hoặc xóa giao dịch
<br>![alt text](manage_transaction.png)<br>

## Liên hệ
- Email: your.email@example.com
- GitHub: username

