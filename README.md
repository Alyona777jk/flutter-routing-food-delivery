# Practical Work 7: Routing and Navigation in Flutter
**Variant 2: Food Delivery App**

An application for ordering food from multiple restaurants built with Flutter and `go_router` (v17.x). The project demonstrates complex route hierarchy with path/query parameters, custom deep linking, route protection via redirects, bottom navigation with tab state preservation, and unsaved changes confirmation using `PopScope`.

---

## Features & Technical Overview

- **Stateful Bottom Navigation:** Implemented using `StatefulShellRoute.indexedStack` across three main tabs:
  - **Restaurants**
  - **Cart**
  - **Orders**
  *(Tab scroll positions and states are fully preserved when switching)*.
- **Route Parameters:** Supports both path parameters (`/restaurants/:restaurantId`) and query parameters (`/restaurants?sort=rating|distance`).
- **Route Guards & Protection:** Dynamic dynamic `redirect` handling using `refreshListenable`:
  - Unauthenticated users attempting to access `/checkout` are redirected to `/login?from=...`.
  - Attempts to checkout with an empty cart redirect back to `/restaurants`.
- **Result Passing:** Uses `context.push<T>()` and `context.pop(result)` to select delivery addresses on `SelectAddressScreen` and return them back to the Cart.
- **Form Protection:** `PopScope` on the checkout screen prevents accidental navigation away when unsaved comments exist.
- **Error Handling:** Custom `errorBuilder` to render a 404 page for unknown routes.
- **Deep Linking:** Configured custom URL scheme `food://app/restaurants/<id>` for both Android and iOS platforms.

---

##  Route Map

| Path | Screen | Access Control / Description |
| :--- | :--- | :--- |
| `/restaurants?sort=rating\|distance` | `RestaurantsScreen` | Public • Query parameter `sort` |
| `/restaurants/:restaurantId` | `RestaurantDetailScreen` | Public • Path parameter `restaurantId` |
| `/restaurants/:restaurantId/dish/:dishId` | `DishScreen` | Public • Nested path parameter `dishId` |
| `/cart?address=...` | `CartScreen` | Public • Tab navigation, optional query parameter `address` |
| `/select-address` | `SelectAddressScreen` | Public • Fullscreen modal returning selected address via `context.pop()` |
| `/checkout?address=...` | `CheckoutScreen` | **Protected:** Redirects if not logged in or if cart is empty. Guarded by `PopScope` |
| `/orders` | `OrdersScreen` | Public • TabBar (Active / Completed) |
| `/login?from=...` | `LoginScreen` | Public • Accepts return path parameter |

---

##  Deep Link Verification Commands

Ensure the application is installed or running on your target emulator before executing the deep link commands.


```bash
MSYS_NO_PATHCONV=1 adb shell am start -W -a android.intent.action.VIEW -d "food://app/restaurants/r1" com.example.food_delivery_app
