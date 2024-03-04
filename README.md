# Space Peggle

A Swift game inspired by the Peggle game. Made with a custom game engine built from ground up.

## User guide

The user guide detailing how to play the game is located at [UserGuide.md](UserGuide.md).
Please read it to understand game behavior.

## Dev Guide

The dev guide containing code explanations is located at [DevGuide.md](DevGuide.md).

## Premade levels

There are three premade levels. These are named Level1, Level2 and Level3. They are found in the level selection list by default, alongside other custom user levels.


## Level designer

### Placing a peg

1. Tap a peg/block button to enter "add" mode
1. Tap the delete button to enter "delete" mode
1. Tapping any peg/block button will deselect it to enter "select" mode

1. When a peg is chosen:
    - Tap to place a peg
    - Drag to move a peg
    - Resize/rotate the peg using drag handles

1. When the delete button is chosen:
    - Tap to remove a peg

### Resizing and rotating pegs

1. Select a peg by tapping on it when not in delete mode.
1. A selection box will appear around it, with a rotation handle at the top, and 4 resizing handles at the corners.
1. Drag the rotation handle around to rotate the peg.
1. Drag the resizing handles to resize the peg.
   - Note: pegs can only be resized to minimum size of half their original size.
   - Note: the aspect ratio of the peg will be maintained throughout the resizing process.
   - Note: Only blocks can have their aspect ratio changed. Pegs maintain their aspect ratio throughout scaling.

### Adding HP

When any placed object is selected, HP can be added to it by using the HP toolbar.

HP buttons:

- No HP button will remove HP from any entity containing it
- 10, 50, 100 HP buttons will set an entity's HP to that value.
- Custom HP button to set custom HP; elaborated below
- Tap a HP button to remove or set the HP of the selected object

Custom HP:

- Enter a custom value into the text field beside the custom HP button to set the custom HP button's value.
- The custom HP value must be a number greater than 0.
- Set the custom HP value by tapping the custom HP button.


## Playing a level

A level can be tested at any time by pressing the "Start" button.
This will play the currently designed level, regardless of whether it has been saved or not.

## Game rules

### Win and lose conditions

The game is won when there are no orange pegs left. The game is lost if there are no balls remaining and there are still orange pegs left.

### Aiming/shooting a ball

The ball can be aimed by tapping or dragging on the screen.
This will show a line, which indicates the direction that the ball will be launched towards.

Note that since gravity is involved, the ball may not land exactly where the line indicates.

Press "Fire" to launch the ball.

> Note: The Fire button will be disabled if the ball has not yet been aimed.

### Hitting pegs

When pegs are hit they will be lit and marked for removal.

When the ball comes to a stop or exits the level at the bottom, the pegs will be removed and the score will be updated.

### Stuck ball

When a ball is stuck, any lit pegs will be removed from the board. If the ball is stuck and there are no lit pegs, the ball will be removed instead.


### Power ups

Hitting a green ball lights it up and activates the currently selected power up. It will not activate another power up for the rest of the turn (while the ball/s are still in play).

#### Kaboom

Pegs within a certain radius of the green ball will be lit.

#### Spooky

The ball will turn "spooky" for 10s after hitting the green peg. When a spooky ball exits the level, it will reappear at the top of the level and continue to bounce around the level until it exits the level again.

If a spooky ball is deemed to be "stuck" falling at high speeds vertically without any pegs to hit, it will be removed from the level.

Spooky balls can still fall into the bucket. The ball will be returned to the player, as per normal


#### Duplicate (new)

ALL cannonballs on the field will be duplicated. This means 1 cannonball will become 2, and 2 will become 4, etc.

#### Points

There are the following pegs in the game. Points are awarded ONLY when the peg is removed from the board. This means that red pegs do not award any points, unless they have HP added to them.

- Orange pegs
  - 0 points
  - Must clear to finish game
- Blue pegs:
  - 100 points
  - Only for score
- Green:
  -  500 points
  - Activates a power up when hit
- Red:
  - 1000 points
  - Stubborn pegs
  - Cannot be removed from the board, unless HP is added
