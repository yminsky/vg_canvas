open! Base
open! Virtual_dom.Vdom

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

let create size view image =
  let arg = (size,view,image) in
  Node.widget ()
    ~id:vg_canvas_id
    ~init:(fun () ->
        let canvas = Dom_html.createCanvas (Dom_html.window ##. document) in
        render canvas size view image;
        (arg, canvas))
    ~update:(fun old_data canvas ->
        (* If there's any change in the input, we rerender the entire
           canvas *)
        if not ([%compare.equal: arg] old_data arg) then
          render canvas size view image;
        (arg, canvas))
