# [STSWENG] Biotech Lab System
An inventory system containing transactions from the company's suppliers and their clients.

## Table of Contents

- [Setup](#setup)
- [Flutter Commands](#flutter-commands)
- [Resources](#resources)


## Setup
1. Clone the repository
```bash
git clone https://github.com/Patthethicc/Biotech_Lab_System
cd Biotech_Lab_System
```
2. Create `.env` files for both:
- `frontend/`
- `lis/`(backend)
3. Delete `pubspec.lock` file in `frontend/` and run:
```bash
flutter clean
flutter pub get
```
4. Access `lis/` and run:
```bash 
cd lis 
mvn spring-boot:run #
```
4. Run the frontend:
```bash
cd frontend 
flutter run
```

## Flutter Commands
- Run Flutter with specific entry:
```bash
flutter run -t lib/models/ui/main.dart
```

## Resources
```bash
https://www.youtube.com/watch?v=7nonQ2dYgiE
https://www.youtube.com/watch?v=3kaGC_DrUnw&t=14157s&pp=ygUOZmx1dHRlciBiYXNpY3M%3D
https://drive.google.com/drive/folders/1W0sP0YdR454hv4nsqipaMKyO52hqEK7J?usp=drive_link
https://lucid.app/lucidchart/6cc17253-19c1-4c40-8893-64e84a1d9a3b/edit?invitationId=inv_93818139-5500-4f1b-8a6e-3166dd1f8d3a&page=0_0#
```




