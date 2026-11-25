(module
  (memory (export "memory") 1)

  ;; 320 by 200 indexed-color pixels, then four signed 16-bit strides.
  ;; Right, down, left, up: +1, +320, -1, -320.
  (data (i32.const 64000) "\01\00\40\01\ff\ff\c0\fe")
  (global $position (mut i32) (i32.const 32160))
  (global $length (mut i32) (i32.const 4))
  (global $remaining (mut i32) (i32.const 4))
  (global $turn (mut i32) (i32.const 0))

  (func (export "reset")
    (memory.fill (i32.const 0) (i32.const 0) (i32.const 64000))
    (global.set $position (i32.const 32160))
    (global.set $length (i32.const 4))
    (global.set $remaining (i32.const 4))
    (global.set $turn (i32.const 0))
    (i32.store8 (i32.const 32160) (i32.const 32)))

  (func (export "step") (result i32)
    (local $count i32)
    (local $color i32)
    (if (i32.eq (global.get $turn) (i32.const 96))
      (then (return (i32.const 1))))

    (loop $draw
      (local.set $color
        (i32.add (i32.const 32) (i32.rem_u (global.get $turn) (i32.const 6))))
      (global.set $position
        (i32.add
          (global.get $position)
          (i32.load16_s
            (i32.add (i32.const 64000)
              (i32.shl (i32.and (global.get $turn) (i32.const 3)) (i32.const 1))))))
      (i32.store8 (global.get $position) (local.get $color))

      (global.set $remaining (i32.sub (global.get $remaining) (i32.const 1)))
      (if (i32.eqz (global.get $remaining))
        (then
          (global.set $turn (i32.add (global.get $turn) (i32.const 1)))
          (if (i32.eq (global.get $turn) (i32.const 96))
            (then (return (i32.const 1))))
          (if (i32.eqz (i32.and (global.get $turn) (i32.const 1)))
            (then (global.set $length (i32.add (global.get $length) (i32.const 4)))))
          (global.set $remaining (global.get $length))))

      (local.set $count (i32.add (local.get $count) (i32.const 1)))
      (br_if $draw (i32.lt_u (local.get $count) (i32.const 32))))
    (i32.const 0)))
