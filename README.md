this repo is a collection of my implementation of godot tutorials:

1. Mouse Game (DONE) 👉 https://www.youtube.com/watch?v=Luf2Kr5s3BM
2. Vampire Survivors Clone (IN PROGRESS) 👉 https://www.youtube.com/playlist?list=PLtosjGHWDab682nfZ1f6JSQ1cjap7Ieeb
3. Top Down Shooter (ON HOLD) 👉 https://www.youtube.com/watch?v=nAh_Kx5Zh5Q&t=937s
4. RPG (TODO) 👉 https://www.youtube.com/playlist?list=PL3cGrGHvkwn0zoGLoGorwvGj6dHCjLaGd

# Notes

## Resizing the Window

to resize the window, adjust

```
[display]

window/size/viewport_width=320
window/size/viewport_height=180
window/size/window_width_override=1920
window/size/window_height_override=1080
window/stretch/mode="canvas_items"
```

## Delta

`move_and_slide()` uses `delta` internally, so it is not required to multiply the velocity by delta. if you build your own movement system, however, make sure to use delta to compensate for framerate.

## Position

a node has a `position` property and `global_position` property. the first is always relative to its parent, while the latter is always relative to world space, i.e. the global `(0,0)` origin. depending on the use case, use one or the other.

## Call Deferred

when changing physics properties inside the physics loop, use `call_deferred`, as described here:

> This is a common problem people have, just as the message says, you can't manipulate the physics state inside of a physics lifecycle callback.
>
> Your \_on_HitBox_area_entered function has a line that disables a collision shape $HitBox/CollisionShape2D.disabled = true. This is a no-no.
>
> You can do something like this instead:

```
func _on_HitBox_area_entered(area):
    call_deferred("_on_HitBox_area_entered_deferred", area)

func _on_HitBox_area_entered_deferred(area):
    # Inject all the code here that was originally in _on_HitBox_area_entered
```

~ https://www.reddit.com/r/godot/comments/ign0y6/comment/g2vohtg/?utm_source=share&utm_medium=web2x&context=3
