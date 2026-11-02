# Face Detection & Smile Analysis

A Flutter app that selects a photo from the device gallery and analyzes it on
device with Google ML Kit Face Detection. The image preview shows a bounding
box for each detected face, alongside total face and smile analytics and
per-face smile information.

## Run the app

```shell
flutter pub get
flutter run
```

Choose **Upload image** to select a photo. Smile classification is enabled, and
a face is considered smiling when ML Kit reports a smile probability of at
least 70%. The smiling percentage is the proportion of detected faces that
meet that threshold; it is 0% when no faces are detected.

## Packages

- `image_picker` for selecting a photo from the device gallery.
- `google_mlkit_face_detection` for on-device face detection and smile
  classification.

## Project structure

The face-analysis feature follows a feature-first MVC layout:

```text
lib/
  main.dart
  features/
    face_analysis/
      controller/
      model/
      view/
        widgets/
```

The controller handles gallery selection and ML Kit analysis, the model holds
the analysis result and derived metrics, and the view contains the screen and
its presentation widgets.
