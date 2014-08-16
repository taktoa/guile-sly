;;; Sly
;;; Copyright (C) 2014 David Thompson <davet@gnu.org>
;;;
;;; Sly is free software: you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; Sly is distributed in the hope that it will be useful, but WITHOUT
;;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
;;; License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see
;;; <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Scene graph
;;
;;; Code:

(define-module (sly scene)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-26)
  #:use-module (sly mesh)
  #:use-module (sly signal)
  #:use-module (sly transform)
  #:use-module (sly transition)
  #:export (scene-node
            make-scene-node
            scene-root
            scene-node?
            scene-node-position scene-node-scale scene-node-rotation
            scene-node-mesh scene-node-uniforms scene-node-children
            update-scene-node draw-scene-node))

(define-record-type <scene-node>
  (%make-scene-node position scale rotation mesh uniforms children)
  scene-node?
  (position %scene-node-position)
  (scale %scene-node-scale)
  (rotation %scene-node-rotation)
  (prev-position scene-node-prev-position set-scene-node-prev-position!)
  (prev-scale scene-node-prev-scale set-scene-node-prev-scale!)
  (prev-rotation scene-node-prev-rotation set-scene-node-prev-rotation!)
  (mesh %scene-node-mesh)
  (uniforms %scene-node-uniforms)
  (children %scene-node-children))

(define-syntax-rule (define/signal-ref name proc)
  (define name (compose signal-ref-maybe proc)))

(define/signal-ref scene-node-position %scene-node-position)
(define/signal-ref scene-node-scale %scene-node-scale)
(define/signal-ref scene-node-rotation %scene-node-rotation)
(define/signal-ref scene-node-mesh %scene-node-mesh)
(define/signal-ref scene-node-uniforms %scene-node-uniforms)
(define/signal-ref scene-node-children %scene-node-children)

(define* (make-scene-node #:optional #:key
                           (position #(0 0))
                           (scale 1)
                           (rotation 0)
                           (mesh #f)
                           (uniforms '())
                           (children '())
                           #:allow-other-keys)
  (%make-scene-node position scale rotation mesh uniforms children))

(define scene-node make-scene-node)

(define (scene-root . children)
  (scene-node #:children children))

(define (update-scene-node node)
  (let ((node (signal-ref-maybe node)))
    (let ((position (scene-node-position node))
          (scale (scene-node-scale node))
          (rotation (scene-node-rotation node)))
      (set-scene-node-prev-position! node position)
      (set-scene-node-prev-scale! node scale)
      (set-scene-node-prev-rotation! node rotation))
    (for-each update-scene-node (scene-node-children node))))

(define (interpolate current prev alpha)
  (if (or (not prev)
          (equal? current prev))
      current
      (vector-interpolate prev current alpha)))

(define (draw-scene-node node alpha transform)
  (let* ((node (signal-ref-maybe node))
         (transform (transform*
                     transform
                     (translate
                      (interpolate (scene-node-position node)
                                   (scene-node-prev-position node)
                                   alpha))
                     (rotate-z (scene-node-rotation node))
                     (scale (scene-node-scale node))))
        (mesh (scene-node-mesh node)))
    (when mesh
      (draw-mesh mesh (cons (list "mvp" transform)
                            (scene-node-uniforms node))))
    (for-each (cut draw-scene-node <> alpha transform)
              (scene-node-children node))))