# Profile Images Directory

This directory contains local profile avatars for the portfolio application.

## How to Add Your Own Profile Images

1. **Add Image Files**: Copy your profile images to this directory
    - Supported formats: JPG, JPEG, PNG
    - Recommended size: 512x512 pixels or higher
    - File naming: Use descriptive names like `profile_professional.jpg`

2. **Update Service**: Add your new images to the `availableAvatars` list in:
   ```
   lib/services/local_profile_service.dart
   ```

3. **Add Display Names**: Update the `getAvatarDisplayName()` method with friendly names

4. **Refresh Assets**: Run `flutter pub get` to refresh the asset bundle

## Example Structure

```
assets/images/profiles/
├── profile1.jpg          (Your main profile photo)
├── profile2.jpg          (Alternative profile photo)
├── profile3.jpg          (Creative/casual photo)
├── profile4.jpg          (Professional photo)
├── default_avatar.png    (Fallback avatar)
└── README.md            (This file)
```

## Usage

- Admin can select from available avatars via Admin Panel → Local Profile
- Selected avatar appears in Hero section and About section
- Changes are saved to Firestore and update in real-time
- No Firebase Storage needed - all images are local assets

## Benefits

- ✅ No Firebase Storage dependency
- ✅ Faster loading (local assets)
- ✅ No upload/bandwidth costs
- ✅ Better privacy (no external uploads)
- ✅ Works offline