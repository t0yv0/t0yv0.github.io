 {-# LANGUAGE OverloadedStrings #-}

import Control.Monad (forM_)
import Text.Blaze.Html5
import Text.Blaze.Html5.Attributes
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A
import qualified Text.Blaze.Html.Renderer.String as S

block name body =
  H.div ! class_ name $ do
    body

space = t " "

linkTo :: String -> String -> Html
linkTo text url = a (toHtml text) ! href (toValue url)

about = do
  t "My work focuses on developing"
  space
  linkTo "WebSharper" "http://websharper.com"
  space
  linkTo "F#" "http://fsharp.org"
  t "-to-JavaScript"
  space
  t "compiler, extending its ecosystem with tools and bindings, and helping"
  space
  t "companies adopt it."

t :: String -> Html
t = toHtml

contact = do
  linkTo "Twitter" "http://twitter.com/t0yv0"
  t " - "
  linkTo "GitHub" "http://github.com/t0yv0"
  t " - "
  linkTo "Blog" "http://t0yv0.blogspot.com"
  br
  linkTo email ("mailto:" ++ email)

email :: String
email = "anton.tayanovskyy@gmail.com"

home =  
  page "HomePage" $
    block "container" $ do
      block "page-header" $ do
        h1 $ do
          t "Anton Tayanovskyy"
          space
          small "[f# hacker]"
      block "row" $ do
        block "col-sm-8" about
        block "col-sm-4" contact
      block "row" $ do
        block "col-sm-8" homeContent

homeContent = do
  h2 "Projects"
  projects
  h2 "Interests"
  interests
  h2 "Skills"
  skills

projects = do
  ul $ do
    li $ do
      linkTo "WebSharper" "http://github.com/intellifactory/websharper"
      t " - features a compiler from a broad F# subset to JavaScript, supports"
      t " server and client-side programming with code sharing, and has an"
      t " ecosystem of libraries built around it.  I work on the compiler itself,"
      t " from code analysis to optimization to generating JavaScript."
    li $ do
      t "ASM.js backend for WebSharper (not yet OSS) - compiles a subset of F#"
      t " to ASM.js for almost-C-speed performance in the browser."
    li $ do
      t "TypeScript Analyzer (not yet OSS) - provides a tool for converting"
      t " TypeScript descriptors of JavaScript libraries into typed bindings"
      t " for WebSharper"
  h3 "Contributions"
  ul $ do
    li $ do
      linkTo "CloudSharper" "http://cloudshaprer.com"
      t " - an upcoming IDE that offers F# and WebSharper as an online service. "
      t " On this IntelliFactory project, I contribute some backend code, "
      t " such as messaging transport, "
      t " Azure hosting, embedding WebSharper."

interests = do
  t "Broadly, I am interested in making computers do more to "
  t "replace error-prone and labor-intensive manual practices, "
  t "such as verifying low-level programs, optimizing by hand, "
  t "or translating existing code between runtimes and languages."

skills = do
  t "Most of my work is with F# on .NET and WebSharper/JavaScript, "
  t "but I explore small projects in a number of related areas."
  ul $ do
    li $ t "Computer-aided theorem proving (Coq)"
    li $ t "Functional programming (Haskell, OCaml, Racket)"
    li $ t "Statistics and data science (R)"

main = do
  putStrLn "Writing index.html.."
  writeFile "index.html" (S.renderHtml home)

bootstrapLink :: String -> String
bootstrapLink url = "bootstrap-3.1.1-dist/" ++ url

css :: String -> Html
css url = H.link ! rel "stylesheet" ! A.type_ "text/css" ! A.href (H.toValue url)

js :: String -> Html
js url = H.script "" ! src (H.toValue url) ! A.type_ "text/javascript"

page :: String -> Html -> Html
page title bodyContent =
  docTypeHtml $ do
    H.head $ do
      H.title (H.toHtml title)
      H.meta ! httpEquiv "X-UA-Compatible" ! content "IE-edge"
      H.meta ! name "viewport" ! content "width=device-width, initial-scale=1"
      css (bootstrapLink "/css/bootstrap.min.css")
      css "style.css"
    H.body $ do
      bodyContent
      js "jquery-1.11.1.min.js"
      js "bootstrap-3.1.1-dist/js/bootstrap.min.js"

