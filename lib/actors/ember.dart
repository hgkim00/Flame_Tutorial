import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_tutorial/actors/water_enemy.dart';
import 'package:flame_tutorial/ember_quest.dart';
import 'package:flame_tutorial/objects/ground_block.dart';
import 'package:flame_tutorial/objects/platform_block.dart';
import 'package:flame_tutorial/objects/star.dart';
import 'package:flutter/src/services/raw_keyboard.dart';

/// [HasGameRef] mixin
/// which allows us to reach back to ember_quest.dart and
/// leverage any of the variables or methods that are defined in the game class
/// [size]
/// the default size of Vector2.all(64) is defined as the size of Ember in our game world should be 64x64
class EmberPlayer extends SpriteAnimationComponent
    with HasGameRef<EmberQuestGame>, KeyboardHandler, CollisionCallbacks {
  EmberPlayer({
    required super.position,
  }) : super(size: Vector2.all(64), anchor: Anchor.center);

  int horizontalDirection = 0;
  final Vector2 velocity = Vector2.zero();
  final double moveSpeed = 200;

  final Vector2 fromAbove = Vector2(0, -1);
  bool isOnGround = false;

  final double gravity = 30;
  final double jumpSpeed = 800;
  final double terminalVelocity = 150;

  bool hasJumped = false;

  bool hitByEnemy = false;

  @override
  FutureOr<void> onLoad() {
    animation = SpriteAnimation.fromFrameData(
      /// game.images.fromCache('ember.png')
      /// Earlier, we loaded all the files into cache, so to use that file now,
      /// we call fromCache so it can be leveraged by the SpriteAnimation
      game.images.fromCache('ember.png'),

      /// [textureSize] is defined as 16x16
      /// This is because the individual frame in our ember.png is 16x16 and there are 4 frames in total
      /// [stepTime]
      /// 0.12 seconds per frame
      SpriteAnimationData.sequenced(
          amount: 4, stepTime: 0.12, textureSize: Vector2.all(16)),
    );
    add(
      CircleHitbox(),
    );
  }

  @override
  void update(double dt) {
    velocity.x = horizontalDirection * moveSpeed;

    if (horizontalDirection < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection > 0 && scale.x < 0) {
      flipHorizontally();
    }
    // Apply basic gravity
    velocity.y += gravity;

    // Determine if ember has jumped
    if (hasJumped) {
      if (isOnGround) {
        velocity.y = -jumpSpeed;
        isOnGround = false;
      }
      hasJumped = false;
    }
    // Prevent ember from jumping to crazy fast as well as descending too fast and
    // crashing through the ground or a platform.
    velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);

    game.objectSpeed = 0;
    // Prevent ember from going backwards at screen edge
    if (position.x - 36 <= 0 && horizontalDirection < 0) {
      velocity.x = 0;
    }
    // Prevent ember from going beyond half screen
    if (position.x + 64 >= game.size.x / 2 && horizontalDirection > 0) {
      velocity.x = 0;
      game.objectSpeed = -moveSpeed;
    }

    position += velocity * dt;

    /// Game Over Condition
    if (position.y > game.size.y + size.y) {
      game.health = 0;
    }
    if (game.health <= 0) {
      removeFromParent();
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalDirection = 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyA) ||
            keysPressed.contains(LogicalKeyboardKey.arrowLeft))
        ? -1
        : 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyD) ||
            keysPressed.contains(LogicalKeyboardKey.arrowRight))
        ? 1
        : 0;
    hasJumped = keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);

    return true;
  }

  /// [intersectionPoints] : 두 객체가 교차하는 영역의 꼭지점들의 좌표
  /// [other] : 충돌한 상대 객체
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GroundBlock || other is PlatformBlock) {
      if (intersectionPoints.length == 2) {
        // Calculate the collision normal and separation distance.
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionNormal = absoluteCenter - mid;
        final separationDistance = (size.x / 2) - collisionNormal.length;
        collisionNormal.normalize();

        // If collision normal is almost upwards,
        // ember must be on ground.
        if (fromAbove.dot(collisionNormal) > 0.9) {
          isOnGround = true;
        }

        // Resolve collision by moving ember along
        // collision normal by separation distance.
        position += collisionNormal.scaled(separationDistance);
      }
    }

    if (other is Star) {
      other.removeFromParent();
      game.starsCollected++;
    }

    if (other is WaterEnemy) {
      hit();
    }

    super.onCollision(intersectionPoints, other);
  }

  // This method runs an opacity effect on ember
  // to make it blink
  void hit() {
    if (!hitByEnemy) {
      game.health--;
      hitByEnemy = true;
    }
    add(
      OpacityEffect.fadeOut(
        EffectController(
          alternate: true,
          duration: 0.1,
          repeatCount: 6,
        ),
      )..onComplete = () {
          hitByEnemy = false;
        },
    );
  }
}