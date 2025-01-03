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
- GET /
Trả về thông tin cơ bản của API
#### User Routes
- POST /api/v1/users/signup
Đăng ký người dùng mới.
- POST /api/v1/users/signin
Đăng nhập người dùng.
- GET /api/v1/users/<userId>
Lấy thông tin người dùng theo ID.
- GET /api/v1/users/username/<username>
Lấy thông tin người dùng theo tên đăng nhập.
- PUT /api/v1/users/<userId>
Cập nhật thông tin người dùng.
- DELETE /api/v1/users/<userId>
Xóa người dùng.
#### Transaction Routes
- GET /api/v1/transactions/<userId>
Lấy tất cả giao dịch của người dùng.
- GET /api/v1/transaction/<transactionId>
Lấy thông tin giao dịch cụ thể theo ID.
- POST /api/v1/transaction
Tạo mới giao dịch.
- PUT /api/v1/transaction/<transactionId>
Cập nhật giao dịch.
- DELETE /api/v1/transaction/<transactionId>
Xóa giao dịch.
- GET /api/v1/transactions/<userId>/aggregate/<key>
Tổng hợp giao dịch theo một tiêu chí (vd: loại giao dịch).
- GET /api/v1/transactions/<userId>/aggregate/<key>/<month>/<year>
Tổng hợp giao dịch theo tháng/năm.

#### Spending Plan Routes
- GET /api/v1/spending-plans/<userId>
Lấy tất cả kế hoạch chi tiêu của người dùng.
- POST /api/v1/spending-plans/<userId>
Tạo hoặc cập nhật kế hoạch chi tiêu.
- DELETE /api/v1/spending-plans/<userId>/<spentPlan>
Xóa kế hoạch chi tiêu.
#### Dashboard Routes
- GET /api/v1/dashBoard/<userId>/networth/current
Lấy giá trị tài sản ròng hiện tại.
- GET /api/v1/dashBoard/<userId>/networth/detail
Lấy chi tiết tài sản ròng.
- GET /api/v1/dashBoard/<userId>/category/current/<numberOfCategory>
Lấy danh mục chi tiêu hiện tại.
- GET /api/v1/dashBoard/<userId>/category/detail
Lấy chi tiết danh mục chi tiêu.
- GET /api/v1/dashBoard/<userId>/spending-plant/current
Lấy thông tin kế hoạch chi tiêu hiện tại.
- GET /api/v1/dashBoard/<userId>/spending-plant/detail/<spentPlan>
Lấy chi tiết kế hoạch chi tiêu.
#### Spending Plan Details
- GET /api/v1/spending-plans/<userId>/<spentPlan>/<type>
Lấy chi tiết kế hoạch chi tiêu theo loại.
### 2. Client
#### User
- ##### sign in
/n![alt text](sign_in.png)/n
- ##### sign up
/n![alt text](sign_up.png)/n
#### Dash board Tab
/n![alt text](dash_board.png)/n
- ##### Total Budget
dùng để theo dõi tổng kết tỉ lệ outcome / income trong tháng
 /n![alt text](total_budget.png)/n
- ##### Spending Plan
dùng để theo dõi tổng kết số dư của plan và tỉ lệ outcome / income trong tháng
/n![alt text](spending_plan.png)/n
- ##### Category Board
hiện thị top category chi tiêu
/n![alt text](category_board.png)/n
#### Spending Plan Tab
/n![alt text](spending_plan_tab.png)/n
- ##### Spending Plan Card
các card có thể trượt sang để xem các plan chi tiêu khác
theo dõi tổng số dư và tỉ lệ outcome / income trong tháng
/n![alt text](spending_plan_card.png)/n
/n![alt text](spending_plan_card1.png)/n
/n![alt text](spending_plan_card2.png)/n
khi ấn hiện thị tỉ lệ giữa các plan
/n![alt text](spending_modal.png)/n
- ##### Spending Plan Chart
các biểu đồ có thể trượt sang để xem các option filter chi tiêu khác
theo dõi tỉ lệ tăng giảm giữa các tháng
/n![alt text](spending_plan_chart.png)/n
/n![alt text](spending_plan_chart1.png)/n
/n![alt text](spending_plan_chart2.png)/n
*Chức năng cho phép người dùng có thể lọc biểu đồ theo tháng đang được phát triển.*
- ##### Spending Plan Detail
/n![alt text](spending_plan_detail.png)/n
*Chức năng cho phép người dùng có thể lọc các giao dịch theo khoảng thời gian đang được phát triển*
#### Category Tab
/n![alt text](category_tab.png)/n
- ##### Category Chart
hiện thị biểu đồ top 4 các category được chi tiêu nhiều nhất trong tháng
/n![alt text](category_chart.png)/n
*Chức năng cho phép người dùng có thể lọc biểu đồ theo top category thay vì 4 category cố định đang được phát triển.*
- ##### Category Detail
hiện thị các category được chi tiêu từ cao đến thấp trong tháng
/n![alt text](category_detail.png)/n
*Chức năng cho phép người dùng có thể các giao dịch theo category được nhấn vào đang được phát triển.*
#### User Tab
/n![alt text](user_tab.png)/n
chức năng chính để người dùng đổi mật khẩu

#### Chức năng thêm giao dịch
/n![alt text](add_transaction.png)/n
*Chức năng cho phép người dùng có thể chuyển nguồn tiền từ các plan đang được phát triển.*

#### Chức năng sửa hoặc xóa giao dịch
/n![alt text](add_transaction.png)/n

## Liên hệ
- Email: your.email@example.com
- GitHub: username

