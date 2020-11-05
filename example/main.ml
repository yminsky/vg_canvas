open! Base
open Async_kernel
open! Incr_dom
module Time_ns = Core_kernel.Time_ns

module App = struct
  module Model = struct
    type t = unit [@@deriving compare]
    let cutoff _ _ = true
    let empty = ()
  end

  module Action = struct
    type t = Nothing.t [@@deriving sexp]
  end

  module State = struct
    type t = unit
  end

  let on_startup ~schedule_action:_ _model = Deferred.unit

  let view =
    let open Vdom in
    let open Incr.Let_syntax in
    let%map now = Incr.Clock.watch_now Incr.clock in
    let canvas =
      let open Gg in
      let open Vg in
      let color =
        I.axial [0.5,Gg.Color.blue; 1.0,Gg.Color.red]
          (V2.v 0. 0.) (V2.v 5. 10.)
      in
      let radius =
        1. +. Base.Float.sin (Time_ns.to_span_since_epoch now |> Time_ns.Span.to_sec)
      in
      let circle =
        I.cut (P.empty |> P.circle (P2.v 5. 5.) radius) color
      in
      Vg_canvas.create
        ~size:(V2.v 100. 100.)
        ~bbox:(Box2.v (V2.v 0. 0.) (V2.v 10. 10.))
        [] circle
    in
    Node.body []
      [ Node.h1 [] [ Node.text "This is a page with a canvas"]
      ; canvas
      ]

  let create model ~old_model:_ ~inject:_ =
    let open Incr.Let_syntax in
    let%map model = model and view = view in
    let apply_action action _ ~schedule_action:_ = Nothing.unreachable_code action in
    Component.create ~apply_action model view
end

let () =
  Start_app.start
    (module App)
    ~bind_to_element_with_id:"app"
    ~initial_model:App.Model.empty
