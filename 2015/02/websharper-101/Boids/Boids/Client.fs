namespace Boids

open WebSharper
open WebSharper.Html.Client
open WebSharper.JavaScript

[<JavaScript>]
module Client =

    let Main () =
        Div [CreateCanvas 480 480 BoidsModel.Animate]
