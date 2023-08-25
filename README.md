# Flame Tutorial

플레임을 처음 사용하는 비기너들을 위한 플러터 프로젝트 레포입니다.

## QnA

```
Q. You may ask, why are the images different sizes?

A. As I was using the online tool to make the assets, I had trouble getting the
detail I desired for the game in a 16x16 block.  The heart worked out in 32x32
and the ground as well as the star were 64x64.  Regardless, the asset size does
not matter for the game as we will resize as needed.
```
## Segment 구조
![image](https://github.com/hgkim00/Flame_Tutorial/assets/61077215/8d0905ac-9c7c-4f5f-a966-6a0550b456ea)
```dart
final segment0 = [
  Block(Vector2(0, 0), GroundBlock),
  Block(Vector2(1, 0), GroundBlock),
  Block(Vector2(2, 0), GroundBlock),
  Block(Vector2(3, 0), GroundBlock),
  Block(Vector2(4, 0), GroundBlock),
  Block(Vector2(5, 0), GroundBlock),
  Block(Vector2(5, 1), WaterEnemy),
  Block(Vector2(5, 3), PlatformBlock),
  Block(Vector2(6, 0), GroundBlock),
  Block(Vector2(6, 3), PlatformBlock),
  Block(Vector2(7, 0), GroundBlock),
  Block(Vector2(7, 3), PlatformBlock),
  Block(Vector2(8, 0), GroundBlock),
  Block(Vector2(8, 3), PlatformBlock),
  Block(Vector2(9, 0), GroundBlock),
];
```
