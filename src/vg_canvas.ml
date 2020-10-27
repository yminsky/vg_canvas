open! Base
open! Virtual_dom.Vdom
open Js_of_ocaml

let render canvas size view image =
  let renderer = Vg.Vgr.create (Vgr_htmlc.target canvas) `Other  in
  let render inst =
    match Vg.Vgr.render renderer inst with
    | `Ok -> ()
    | `Partial -> raise_s [%message "Vgr.render failed unexpectedly"]
  in
  render (`Image (size,view,image));
  render `End

let vg_canvas_id =
  Type_equal.Id.create
    ~name:"vg-canvas"
    [%sexp_of: _]

type arg = Gg.V2.t * Gg.Box2.t * Vg.I.t
[@@deriving compare]

let create ~size ~bbox attrs image =
  let arg = (size,bbox,image) in
  let init () =
    let canvas : Dom_html.canvasElement Js.t =
      Node.create "canvas" attrs []
      |> Node.to_dom
      |> Js.Unsafe.coerce
    in
    render canvas size bbox image;
    ((attrs,arg), canvas)
  in
  let update (old_attrs, old_arg) canvas =
    (* CR yminsky: This is not ideal behavior. It would be better
       to leave the canvas in place, and re-set the attributes *)
    (* If the attributes change, rerender the entire node *)
    if not (List.equal phys_equal old_attrs attrs) then
      init ()
    else (
      (* If a change in the thing to render, we rerender *)
      if not ([%compare.equal: arg] old_arg arg) then
        render canvas size bbox image;
      ((attrs,arg), canvas))
  in
  Node.widget ~id:vg_canvas_id ~init ~update ()
