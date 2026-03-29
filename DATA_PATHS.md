# Đường dẫn / cấu hình data (AppFood) — đã kiểm tra

Gốc repo: thư mục chứa **`backend/`** và **`appfood/`** (Flutter, có `pubspec.yaml`).

## API Flutter

| Mục | Đường dẫn / giá trị |
|-----|----------------------|
| Cấu hình | `appfood/lib/common/globs.dart` |
| Cổng hiện tại | **`5050`** (khớp `Globs.port` và `backend/.env`) |
| iOS Simulator / macOS / Linux | `http://127.0.0.1:5050` |
| Android Emulator | `http://10.0.2.2:5050` |
| Máy thật (Wi‑Fi) | `flutter run --dart-define=API_HOST=<IP máy chạy Node>` |

Endpoint mẫu: `/api/auth/login`, `/api/food/items`, **`POST /api/food/checkout`**, … (xem `globs.dart`). Đơn lưu bảng `orders` / `order_items` trong PostgreSQL.

## Asset & font

| Mục | Đường dẫn |
|-----|-----------|
| Ảnh (đã khai báo) | `appfood/assets/img/` → trong `pubspec.yaml`: `- assets/img/` |
| Font Satoshi | `appfood/assets/font/*.otf` |
| Khai báo | `appfood/pubspec.yaml` → `flutter:` → `assets:` / `fonts:` |

## Backend & môi trường

| File | Nội dung chính |
|------|----------------|
| `backend/.env` | `PORT=5050`, `DB_*`, `JWT_SECRET`, … |
| `backend/server.js` | `GET /api/health`, listen `0.0.0.0`, mặc định port **5050** |

## PostgreSQL

- File data nằm trong **data directory của PostgreSQL** trên máy, không trong repo.
- Database: theo `.env` hiện tại là **`appfood_db`**.
- Schema / seed: `backend/config/db.js`, `backend/config/seed.js`.

## Kiểm tra API đang chạy

```bash
curl -s http://127.0.0.1:5050/api/health
```

Kỳ vọng: JSON có `"service":"appfood-api"`. Đổi cổng trong URL nếu bạn đổi `PORT` trong `.env` **và** `Globs.port` cho khớp.
