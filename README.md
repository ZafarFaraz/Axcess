# Axcess

Axcess is designed as an accessibility app to allow people with accessibility needs to interact using alternative forms of interaction such as eye trackers, scanners, etc. The app is designed to combine various applications under one banner to allow users to communicate their needs and gain some form of independence without being a burden on their support system (family and relatives).

## Features

The app includes the following applications:
1. **Text-to-Speech**
2. **Smart Home**
3. **Note Taking/Reminders**
4. **Caller (Keypad / Contacts)**

## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK (comes with Flutter)
- An IDE with Flutter support (VSCode, Android Studio, etc.)

### Installation

1. **Clone the repository**
    ```sh
    git clone https://github.com/ZafarFaraz/axcess.git
    cd axcess
    ```

2. **Install dependencies**
    ```sh
    flutter pub get
    ```

3. **Run the app**
    ```sh
    flutter run
    ```

## Folder Structure

The project follows a standard Flutter project structure:

- `android/` - Android-specific code and configurations.
- `assets/` - Assets used in the app (images, fonts, etc.).
- `ios/` - iOS-specific code and configurations.
- `lib/` - Main Flutter codebase.
  - `assets/` - Local assets {images/json}.
  - `components/` - Reusable UI components.
  - `pages/` - different tabs in the navigation bar
    - `tts/` - text to speech (TTS) functionality
    - `home/` - controlling home accessories
    - `notes/` - taking notes or adding reminders
  - `main.dart` - Entry point of the application.
- `test/` - Unit and widget tests.
- `pubspec.yaml` - Flutter project configurations and dependencies.
- `README.md` - Project documentation.

## Usage

### Text-to-Speech

The Text-to-Speech feature allows users to convert typed text into spoken words. It is designed to aid users who may have difficulty speaking.

### Smart Home

The Smart Home feature allows users to control smart home devices using the app. It utilises homeKit functionality from SWIFT to populate and work with different smart home apps already listed in the Home App

### Note Taking/Reminders

This feature allows users to take notes and set reminders. It helps users keep track of their tasks and important events.

### Caller

This section allows you to dial a number using your cell provider or call a number from your contacts

## Screenshots

### Text to Speech

<img width="1194" alt="image" src="https://github.com/user-attachments/assets/952d0e59-616d-48c9-89b9-a3fe538dc0cd">

### Smart Home

<img width="1194" alt="image" src="https://github.com/user-attachments/assets/e29a7953-3d60-472e-8ebc-e3acb2e12fec">

### Caller

![IMG_0005](https://github.com/user-attachments/assets/fe0a30ac-bc04-4121-a9c3-aafa66c5ec6e)

![IMG_0006](https://github.com/user-attachments/assets/f44d3512-7c75-47fb-873f-a114d22bf876)
#### Hiding contact details for privacy reasons

### Notes

![Screenshot 2024-07-15 at 7 25 35 PM](https://github.com/user-attachments/assets/d39c3662-085c-4cea-b70a-755870e5dfd1)


## Contributing

Contributions are welcome! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) for details on the code of conduct, and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to the Flutter community for providing excellent resources and support.
- Thanks to all contributors and users for their feedback and contributions.

## Contact

If you have any questions, feel free to reach out:

- Email: [zafaraz26](mailto:zafaraz26@gmail.com)
- GitHub: [Zafar Faraz](https://github.com/ZafarFaraz)

