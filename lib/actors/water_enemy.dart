import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_tutorial/ember_quest.dart';

class WaterEnemy extends SpriteAnimationComponent
    with HasGameRef<EmberQuestGame> {
  final Vector2 gridPosition;
  double xOffset;

  final Vector2 velocity = Vector2.zero();

  WaterEnemy({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  FutureOr<void> onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('water_enemy.png'),
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.7,
        textureSize: Vector2.all(16),
      ),
    );
    position = Vector2(
      (gridPosition.x * size.x) + xOffset + (size.x / 2) - 35,
      game.size.y - (gridPosition.y * size.y) - (size.y / 2) + 35,
    );
    add(RectangleHitbox(collisionType: CollisionType.passive));
    add(MoveEffect.by(
        Vector2(-2 * size.x, 0),
        EffectController(
          duration: 3,
          alternate: true,
          infinite: true,
        )));
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;
    if (position.x < -size.x || game.health <= 0) {
      removeFromParent();
    }
    super.update(dt);
  }
}
