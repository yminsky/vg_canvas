open! Base
open! Incr_dom
module Time_ns = Core_kernel.Time_ns

module App = struct
  module Model = struct
    type t = unit [@@deriving compare]
    let cutoff _ _ = true
    let empty = ()
  end

  module Action = struct
    type t = unit [@@deriving sexp]
    let should_log _ = true
  end

  module State = struct
    type t = unit
  end

  let apply_action _ m _ = m
  let update_visibility m = m

  let on_startup ~schedule:_ _ =
    Async_kernel.return ()

  let on_display ~old:_ _ _ = ()

  let view m ~inject:_ =
    let open Vdom in
    let open Incr.Let_syntax in
    let%map _ = m in
    let canvas =
      let open Gg in
      let open Vg in
      let color =
        I.axial [0.5,Gg.Color.blue; 1.0,Gg.Color.red]
          (V2.v 0. 0.) (V2.v 5. 10.)
      in
      let radius = 3. in
      let circle =
        I.cut (P.empty |> P.circle (P2.v 5. 5.) radius) color
      in
      Vg_canvas.create
        ~size:(V2.v 100. 100.)
        ~bbox:(Box2.v (V2.v 0. 0.) (V2.v 10. 10.))
        circle
    in
    Node.body []
      [Node.h1 [] [ Node.text "This is a page with a canvas"
                  ; Node.create "br" [] []
                  ; canvas
                  ]]
end

let () =
  Start_app.simple
    (module App)
    ~initial_model:App.Model.empty
