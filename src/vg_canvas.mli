open! Base
open! Virtual_dom.Vdom

(* CR yminsky: Should make it possible to set attributes here, by
   passing in a Vdom.Attr.t list *)
(** Creates a widget for rendering a Vg image. [size] is measured in
    millimeters, and determines the size of the final rendered view.
    The bounding box, [bbox], is in the same dimension as the image is
    specified in. *)
val create : size:Gg.v2 -> bbox:Gg.box2 -> Attr.t list -> Vg.image -> Node.t
