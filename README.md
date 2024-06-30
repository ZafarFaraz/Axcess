# Axcess

Axcess is designed as an accessibility app to allow people with accessibility needs to interact using alternative forms of interaction such as eye trackers, scanners, etc. The app is designed to combine various applications under one banner to allow users to communicate their needs and gain some form of independence without being a burden on their support system (family and relatives).

## Features

The app includes the following applications:
1. **Text-to-Speech**
2. **Smart Home**
3. **Note Taking/Reminders**
4. **PDF Reader**

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

### PDF Reader

The PDF Reader allows users to read PDF documents. It includes features like text scaling, page navigation, and more.

## Contributing

Contributions are welcome! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) for details on the code of conduct, and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to the Flutter community for providing excellent resources and support.
- Thanks to all contributors and users for their feedback and contributions.

## Contact

If you have any questions, feel free to reach out:

- Email: [your-email@example.com](mailto:zafaraz26@gmail.com)
- GitHub: [your-username](https://github.com/ZafarFaraz)

