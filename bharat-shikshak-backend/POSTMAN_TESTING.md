# Postman API testing

## 1. Start the API and database

1. Ensure `DATABASE_URL` and `JWT_SECRET` are set in `.env`.
2. Apply the Prisma schema to the intended database: `npx prisma db push`.
3. Optionally load the supplied teacher/classes/students: `npm run prisma:seed`.
4. Start the server: `npm run dev`.
5. Confirm `GET http://localhost:5000/health` returns HTTP 200.

## 2. Import and configure the collection

Import `postman/Bharat-Shikshak-Backend.postman_collection.json` into Postman. Its default `baseUrl` is `http://localhost:5000/api/v1`; change it only when testing a deployed server.

## 3. Authenticate and get the bearer token

Run **Auth > Register** once using a unique employee ID and email. The response is HTTP 201 and has this shape:

```json
{ "success": true, "user": { "id": "...", "fullName": "..." }, "token": "eyJ..." }
```

The collection automatically stores that `token` in its `bearerToken` collection variable. You can also copy it manually and set it in Postman's **Collection > Variables** tab.

Run **Auth > Login** on later runs. Use either `employeeId` or `email` plus the password. It returns HTTP 200 and refreshes `bearerToken` automatically.

For protected requests, send this header:

```http
Authorization: Bearer {{bearerToken}}
```

Postman also retains the `accessToken` cookie sent by login. The cookie is HTTP-only and cannot be copied from JavaScript by design; the JSON `token` is the value to use as a Postman Bearer token.

## 4. Test in this order

1. **User > Get My Profile** — checks authentication and returns the logged-in teacher.
2. **Class > Get My Classes** — saves the first class as `classId` automatically. A newly registered teacher has no classes; use the seeded teacher/classes or create class data directly in the database before testing class-dependent endpoints.
3. **Class > Get Class Students** — saves the first student as `studentId`.
4. **Attendance > Mark Attendance**, then **Get Class Attendance**.
5. **Library > Add Resource**, then **Get Resources**.
6. **AI > Ask Sahayak**.

Use a date such as `2026-09-16` for `attendanceDate`. Valid statuses are `PRESENT`, `ABSENT`, and `LATE`.

## Expected errors

- `401`: token missing, expired, malformed, or signed with another secret.
- `403`: logged-in teacher does not own the requested class.
- `404`: user or class does not exist.
- `409`: employee ID or email is already registered.
- `400`: request body/query is invalid, or a student does not belong to the requested class.
