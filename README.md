# PlayTogether (Roblox Starter Kit)

Bộ mã mẫu để bạn bắt đầu làm game social kiểu **Play Together** trên Roblox, gồm 3 phần chính:

- **Party system**: mời người chơi vào nhóm.
- **Daily reward + coins**: nhận thưởng điểm danh mỗi ngày.
- **HUD client**: hiển thị coins, party và nút nhận thưởng.

## Cấu trúc thư mục

```text
roblox/
  shared/
    RemoteDefinitions.lua
  server/
    Main.server.lua
    PlayerDataService.lua
    PartyService.lua
  client/
    Main.client.lua
```

## Cách gắn vào Roblox Studio

1. Tạo folder `PlayTogetherModules` trong `ReplicatedStorage` và thêm `RemoteDefinitions.lua` vào đó dưới dạng **ModuleScript**.
2. Thêm `PlayerDataService.lua`, `PartyService.lua`, `Main.server.lua` vào `ServerScriptService`.
3. Thêm `Main.client.lua` vào `StarterPlayer > StarterPlayerScripts`.
4. Bật API Services để DataStore hoạt động khi test publish place.

## Luồng hoạt động

- Server load/sync dữ liệu coins khi player vào game.
- Client bấm nút điểm danh sẽ gọi `RequestCoinReward`.
- Server kiểm tra ngày hiện tại, cộng coins nếu hợp lệ, rồi gửi kết quả về client.
- Party được quản lý tập trung ở server; mọi thay đổi sẽ broadcast tới thành viên trong party.

## Gợi ý mở rộng

- Hệ thống nhà/căn hộ và đồ nội thất.
- Mini-game kiếm tiền + XP.
- Nhiệm vụ ngày/tuần và battle pass.
- Chat channel riêng cho party.
- Matchmaking cho sự kiện co-op.
