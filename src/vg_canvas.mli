open! Base
open! Virtual_dom.Vdom

(** Creates a widget for rendering a Vg image *)
val create : Gg.v2 -> Gg.box2 -> Vg.image -> Node.t
