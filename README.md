# Práctica MBaas iOs Swift Firebase - KeepCoding

- Published post's list
- Login with Facebook
- Post's list for user
- Post creation with GPS and Image Loading
- Image Saving to device only the first loading time
- Change post state to published
- Delete post
- Firebase Analytics working
- Added Firebase Cloud Messaging. You can only send push notifications from Firebase Console

## Realtime Database RULES

```JSON
{
  "rules": {
    ".read": "true",
    ".write": "true",
    "Post": {
      ".indexOn": ["creationDate", "userid", "published"]
    }
  },
}
```
