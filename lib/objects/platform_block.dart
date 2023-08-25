import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_tutorial/ember_quest.dart';

class PlatformBlock extends SpriteComponent with HasGameRef<EmberQuestGame> {
  final Vector2 gridPosition;
  double xOffset;

  PlatformBlock({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  final Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    final platformImage = game.images.fromCache('block.png');
    sprite = Sprite(platformImage);
    position = Vector2(
      (gridPosition.x * size.x) + xOffset,
      game.size.y - (gridPosition.y * size.y),
    );
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;

    /// dt는 "delta time"의 약자로, 이전 프레임과 현재 프레임 사이의 시간 간격을 초 단위로 나타낸다
    /// 객체가 화면에서 움직일 때 일정한 속도를 유지하도록 하기 위해 사용 (프레임율에 관련없이 일정한 움직임 보장)
    position += velocity * dt;
    if (position.x < -size.x || game.health <= 0) removeFromParent();

    super.update(dt);
  }
}
