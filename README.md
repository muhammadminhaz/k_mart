# K Mart

**K Mart** is a premium, user-friendly marketplace application tailored specfically for KAU students. It bridges the gap between buyers and sellers within the campus, providing a secure and seamless platform to trade items.

With a focus on simplicity and efficiency, K Mart ensures that listings are fresh and relevant by implementing a 30-day expiry system. Whether you're selling textbooks, electronics, or dorm essentials, K Mart makes the process effortless.

---

## Key Features

-   **📱 Intuitive User Interface**: A clean, modern, and responsive design ensures a smooth user experience across all devices.
-   **🛍️ Easy Listing Management**: Users can effortlessly upload items with photos, descriptions, and prices using the integrated image picker.
-   **⏳ Smart Expiry System**: To prevent clutter, all item listings automatically expire after **30 days**, ensuring the marketplace remains up-to-date.
-   **💬 Direct Communication**: Buyers can instantly contact sellers via **Email** or direct links to negotiate and finalize deals.
-   **🔍 Advanced Search & Filtering**: Quickly find what you need with optimized search capabilities.
-   **🖼️ Optimized Media**: Uses `cached_network_image` for fast image loading and bandwidth efficiency.
-   **🔔 Interactive Feedback**: Real-time user feedback using Toast notifications for all actions.

## Technologies Used

This project is built with a robust tech stack to ensure performance and scalability:

-   **Frontend**: [Flutter](https://flutter.dev/) (Dart)
-   **Backend**: [Firebase](https://firebase.google.com/)
    -   **Cloud Firestore**: For real-time database management of users and products.
    -   **Firebase Storage**: For secure and scalable image hosting.
-   **State & Logic**: Standard Flutter MVC architecture.
-   **Key Packages**:
    -   `image_picker`: For gallery and camera access.
    -   `fluttertoast`: For non-intrusive user notifications.
    -   `introduction_screen`: For a welcoming onboarding experience.
    -   `shared_preferences`: For local data persistence.
    -   `url_launcher` & `flutter_email_sender`: For bridging communication between users.

---

## Screenshots

|                         **Home Dashboard**                          | **Item Details**|                           **Upload Item**                           
|:-------------------------------------------------------------------:|:---:|:-------------------------------------------------------------------:|
| <img src="assets/screenshots/phone screenshot_1.png" width="250" /> | <img src="assets/screenshots/phone screenshot_2.png" width="250" /> | <img src="assets/screenshots/phone screenshot_4.jpg" width="250" /> |

---

## Getting Started

Follow these steps to set up the project locally.

### Prerequisites

-   Flutter SDK installed.
-   A Firebase project set up with Firestore and Storage enabled.

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/muhammadminhaz/k_mart.git
    ```
2.  **Navigate to the project directory**:
    ```bash
    cd k_mart
    ```
3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run the application**:
    ```bash
    flutter run
    ```

---

## Contributing

Contributions are welcome! If you have any suggestions or improvements, please create a pull request or open an issue.
