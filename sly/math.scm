;;; Sly
;;; Copyright (C) 2013, 2014 David Thompson <dthompson2@worcester.edu>
;;; Copyright (C) 2014 Jordan Russell <jordan.likes.curry@gmail.com>
;;;
;;; This program is free software: you can redistribute it and/or
;;; modify it under the terms of the GNU General Public License as
;;; published by the Free Software Foundation, either version 3 of the
;;; License, or (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see
;;; <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Miscellaneous math procedures. Currently just trigonometry.
;;
;;; Code:

(define-module (sly math)
  #:export (pi 2pi pi/2
            degrees->radians
            radians->degrees
            sin-degrees
            cos-degrees
            tan-degrees
            atan-degrees
            cotan
            clamp
            linear-scale
            half square
            make-lerp lerp
            modulo*))

;; Dave was editing this module on Pi Approximation Day.
;;
;;       3.141592653589793238462643383279
;;     5028841971693993751058209749445923
;;    07816406286208998628034825342117067
;;    9821    48086         5132
;;   823      06647        09384
;;  46        09550        58223
;;  17        25359        4081
;;            2848         1117
;;            4502         8410
;;            2701         9385
;;           21105        55964
;;           46229        48954
;;           9303         81964
;;           4288         10975
;;          66593         34461
;;         284756         48233
;;         78678          31652        71
;;        2019091         456485       66
;;       9234603           48610454326648
;;      2133936            0726024914127
;;      3724587             00660631558
;;      817488               152092096
;;
(define pi 3.141592654)
(define 2pi (* pi 2))
(define pi/2 (/ pi 2))

(define (degrees->radians angle)
  "Convert ANGLE in degrees to radians."
  (* angle (/ pi 180)))

(define (radians->degrees angle)
  "Convert ANGLE in radians to degrees."
  (* angle (/ 180 pi)))

(define (sin-degrees angle)
  "Compute the sin of ANGLE expressed in degrees."
  (sin (degrees->radians angle)))

(define (cos-degrees angle)
  "Compute the cosine of ANGLE expressed in degrees."
  (cos (degrees->radians angle)))

(define (tan-degrees angle)
  "Compute the tangent of ANGLE expressed in degrees."
  (tan (degrees->radians angle)))

(define (atan-degrees y x)
  "Compute the arctangent in degrees of the coordinates Y and X."
  (radians->degrees (atan y x)))

(define (cotan z)
  "Return the cotangent of Z."
  (/ 1 (tan z)))

(define (clamp min max x)
  "Restrict X to the range defined by MIN and MAX. Assumes that MIN is
actually less than MAX."
  (cond ((< x min) min)
        ((> x max) max)
        (else x)))

(define (linear-scale min max a b n)
  "Map a number N in the range [MIN,MAX] to the range [A,B]."
  (+ a
     (/ (* (- b a) (- n min))
        (- max min))))

(define (half x)
  (/ x 2))

(define (square x)
  (* x x))

(define (make-lerp + *)
  "Return a new procedure that accepts three arguments: START, END,
and ALPHA.  The returned procedure uses the procedures + and * to
linearly interpolate a value between START and END.  ALPHA should
always be in the range [0, 1]."
  (lambda (start end alpha)
    (+ (* start (- 1 alpha))
       (* end alpha))))

(define lerp (make-lerp + *))

(define (modulo* x y)
  "Return the remainder of X / Y.  X and Y may be exact integers,
rational numbers, or inexact numbers."
  (- x (* (floor (/ x y)) y)))
