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
;; A mesh is a 2D/3D model comprised of a shader and vertex buffers.
;;
;;; Code:

(define-module (sly mesh)
  #:use-module (oop goops)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-9)
  #:use-module (system foreign)
  #:use-module (gl)
  #:use-module (gl low-level)
  #:use-module (sly wrappers gl)
  #:use-module (sly color)
  #:use-module (sly shader)
  #:use-module (sly texture)
  #:use-module (sly math vector)
  #:use-module (sly signal)
  #:use-module (sly transform)
  #:use-module (sly render utils)
  #:use-module (sly render vertex-array)
  #:use-module (sly render renderer)
  #:export (make-mesh
            mesh?
            mesh-length
            mesh-shader
            mesh-texture
            mesh->render-op))

;;;
;;; Mesh
;;;

(define-record-type <mesh>
  (%make-mesh vao shader texture)
  mesh?
  (vao mesh-vao)
  (shader mesh-shader)
  (texture mesh-texture))

(define* (make-mesh #:optional #:key shader texture indices positions textures)
  (%make-mesh (make-vertex-array indices positions textures)
              shader texture))

(define-method (draw (mesh <<mesh>>) transform)
  (make-render-op #:vertex-array (mesh-vao mesh)
                  #:texture (mesh-texture mesh)
                  #:shader (mesh-shader mesh)
                  #:uniforms `(("color" ,white))
                  #:transform transform))
