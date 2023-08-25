import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tutorial/actors/ember.dart';
import 'package:flame_tutorial/actors/water_enemy.dart';
import 'package:flame_tutorial/objects/ground_block.dart';
import 'package:flame_tutorial/objects/platform_block.dart';
import 'package:flame_tutorial/objects/star.dart';
import 'package:flame_tutorial/overlays/hud.dart';
import 'package:flutter/material.dart';

import 'managers/segment_manager.dart';

class EmberQuestGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  EmberQuestGame();

  late EmberPlayer _ember;
  double objectSpeed = 0.0;

  final world = World();
  late final CameraComponent cameraComponent;

  late double lastBlockXPosition = 0.0;
  late UniqueKey lastBlockKey;

  /// HUD(Head-Up Display)
  int starsCollected = 0;
  int health = 3;

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  @override
  Future<FutureOr<void>> onLoad() async {
    print('size.x: ${size.x}');
    await images.loadAll([
      'block.png',
      'ember.png',
      'ground.png',
      'heart_half.png',
      'heart.png',
      'star.png',
      'water_enemy.png'
    ]);

    cameraComponent = CameraComponent(world: world);
    // Everything in this tutorial assumes that the position
    // of the `CameraComponent`s viewfinder (where the camera is looking)
    // is in the top left corner, that's why we set the anchor here.
    cameraComponent.viewfinder.anchor = Anchor.topLeft;
    addAll([cameraComponent, world]);

    initializeGame(true);
  }

  @override
  void update(double dt) {
    if (health <= 0) {
      overlays.add('GameOver');
    }
    super.update(dt);
  }

  void loadGameSegments(int segmentIndex, double xPositionOffset) {
    for (final block in segments[segmentIndex]) {
      switch (block.blockType) {
        case GroundBlock:
          add(
            GroundBlock(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset,
            ),
          );
          break;
        case PlatformBlock:
          add(PlatformBlock(
              gridPosition: block.gridPosition, xOffset: xPositionOffset));
          break;
        case Star:
          add(Star(gridPosition: block.gridPosition, xOffset: xPositionOffset));
          break;
        case WaterEnemy:
          add(
            WaterEnemy(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset,
            ),
          );
          break;
      }
    }
  }

  void initializeGame(bool loadHud) {
    // Assume that [size.x] < 3200
    /// 왜 640이 기준인가?
    /// Each segment is a 10x10 grid and each block is 64 pixels x 64 pixels
    /// => 10 * 64 = 640
    final segmentsToLoad = (size.x / 640).ceil();
    segmentsToLoad.clamp(0, segments.length);

    for (var i = 0; i <= segmentsToLoad; i++) {
      loadGameSegments(i, (640 * i).toDouble());
    }

    _ember = EmberPlayer(
      position: Vector2(128, canvasSize.y - 128),
    );
    world.add(_ember);

    if (loadHud) {
      add(Hud());
    }
  }

  void reset() {
    starsCollected = 0;
    health = 3;
    initializeGame(false);
  }
}
