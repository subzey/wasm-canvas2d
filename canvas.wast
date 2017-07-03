(module
	;; import ctx.beginPath as a function with no arguments and void result
	(func $beginPath (import "ctx" "beginPath"))

	;; import ctx.stroke as a function with no arguments and void result
	(func $stroke (import "ctx" "stroke"))

	;; import ctx.lineTo as a function with 2 float64 arguments and void result
	(func $lineTo (import "ctx" "lineTo") (param $x f64) (param $y f64))

	;; import ctx.lineTo as a function with 4 float64 arguments and void result
	(func $clearRect (import "ctx" "clearRect") (param $x f64) (param $y f64) (param $w f64) (param $h f64))

	;; import Math.sin as a function float64 => float64
	(func $sin (import "Math" "sin") (param $angle f64) (result f64))

	;; declare anonymous function and export right away as "draw"
	(func (export "draw") (param $timestamp f64)
		;; let phase: float64 = 0
		(local $phase f64)
		;; let count: int32 = 0
		(local $count i32)

		;; clean up canvas
		(call $clearRect
			(f64.const 0) (f64.const 0) (f64.const 300) (f64.const 150)
		)

		;; NOTE: It looks like arguments, but actually, it's just an another way to push
		;; values on top of the stack.
		;; `(call $clearRect (f64.const 0) (f64.const 0) (f64.const 300) (f64.const 150) )`
		;; is just the same as
		;; `(f64.const 0) (f64.const 0) (f64.const 300) (f64.const 150) (call $clearRect)`
		;; But it's clearly more readable ...until the nesting become too deep.



		;; ctx.beginPath()
		(call $beginPath)

		;; count = 3000
		(set_local $count (i32.const 3000))

		;; Mark loop start
		(loop $continue
			;; May the Forth be with you.
			;; (https://en.wikipedia.org/wiki/Forth_(programming_language)#Programmer.27s_perspective)

			(f64.convert_u/i32 (get_local $count)) ;; Treat int32 as unsigned int32 and convert to float
			(f64.add (get_local $timestamp)) ;; Add up with $timestamp
			(f64.div (f64.const 1000)) ;; Divide by 1000 (animation speed)
			(tee_local $phase) ;; Save phase to $phase and leave on top of the stack
			(call $sin) ;; Ask JS Math function to calc sine
			(f64.mul (f64.const 149)) ;; This would be an X coord. Scale by 149
			(f64.add (f64.const 150)) ;; Translate by 150

			;; Stack size here is 1: [f64]

			(get_local $phase) ;; Restore $phase
			(f64.mul (f64.const 1.75)) ;; Multiply by 3/4 to get a nice Lissajous curve
			(f64.const 1.5707963267948966) ;; Pi/2. Wasm is a binary format, so there's no penalty for being too precise
			(f64.add)
			(call $sin) ;; Math.sin(). But since we've added Pi/2, it's actually a cos. Or -cos. Who cares if it looks good?
			(f64.mul (f64.const 74)) ;; This would be an Y coord. Scale by 74
			(f64.add (f64.const 75)) ;; Translate by 75

			;; Stack size here is 2: [f64] [f64]

			;; Call lineTo with two topmost stack values
			(call $lineTo)

			;; Subtract 30 from $count and place result on top of stack
			(i32.sub (get_local $count) (i32.const 30))
			;; Save new value to $count *and leave that value on top of stack*
			(tee_local $count)

			;; Branch ("goto") to the start of the loop if the topmost i32 value is not zero
			(br_if $continue)
		)

		;; Finally, stroke()
		(call $stroke)
	)
)
