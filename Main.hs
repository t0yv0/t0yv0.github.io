{-# OPTIONS -Wall #-}
{-# LANGUAGE OverloadedStrings #-}

--import Control.Monad (forM_)
import Text.Blaze.Html5
import Text.Blaze.Html5.Attributes
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A
import qualified Text.Blaze.Html.Renderer.String as S

block :: String -> Html -> Html
block clName blBody = H.div ! class_ (toValue clName) $ blBody

space :: Html
space = t " "

linkTo :: String -> String -> Html
linkTo text url = a (toHtml text) ! href (toValue url)

about :: Html
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

contact :: Html
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

home :: Html
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
      vskip
      block "row" $ do
        block "col-sm-8" homeContent

data Tab = Tab { tabLabel :: String, tabHash :: String, tabBody :: Html }
data Tabs = Tabs [Tab]

tabs :: Tabs -> Html
tabs (Tabs ts) = do
  ul ! class_ "nav nav-tabs" $ sequence_ [ tHeader j ta | (j, ta) <- zip ns ts ]
  H.div ! class_ "tab-content" $ sequence_ [ tBody j ta | (j, ta) <- zip ns ts ]
  where
    ns :: [Int]
    ns = [1..]
    tHeader j ta =
      liTag j (linkTo (tabLabel ta) (tabHash ta) ! dataAttribute "toggle" "tab") where
      liTag 1 = li ! class_ "active"
      liTag _ = li
    tBody j ta = pane j ! A.id (toValue $ drop 1 $ tabHash ta) $ do
      vskip
      tabBody ta
    pane 1 = H.div ! class_ "tab-pane active"
    pane _ = H.div ! class_ "tab-pane"

projectsTab :: Tab
projectsTab = Tab "Projects" "#projects" $ do
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

vskip :: Html
vskip = H.div ! A.style "height: 1em" $ return ()

servicesTab :: Tab
servicesTab = Tab "Services" "#services" $ do
  p $ do
    t "I am deeply familiar with F# and have \
      \succesfully helped clients in both \
      \industry and academia to"
  ul $ do
    li $ t "optimize F# code"
    li $ t "optimize WebSharper/JS code"
    li $ t "develop interactive visualizations for scientific software (biology)"
  p $ do
    t "As it turns out, a surprising number of problems reduces \
        \neatly to building a proper domain-specific language or \
        \defining custom optimization/rewrite rules for a compiler. "
  p $ do
    t "While most of my current work is with IntelliFactory where we are using F# \
        \on CLR and JavaScript via WebSharper, "
    t "I explore small projects in"
  ul $ do
    li $ t "computer-aided theorem proving (Coq)"
    li $ t "functional programming (Haskell, OCaml, Racket)"
    li $ t "statistics and data science (R)"
  p $ do
    t "I also have an Economics MA which included \
      \training in statistics."
  p $ do
    t "If it sounds like I could help you with your project, let us talk. \
      \I do contract work in both consultant and developer roles."

talksTab :: Tab
talksTab = Tab "Talks" "#talks" $ do
  t "TBC.."

linksTab :: Tab
linksTab = Tab "Links" "#links" $ do
  t "TBC.."

interestsTab :: Tab
interestsTab = Tab "Interests" "#interests" $ do
  t "Broadly, I am interested in making computers do more to "
  t "replace error-prone and labor-intensive manual practices, "
  t "such as verifying low-level programs, optimizing by hand, "
  t "or translating existing code between runtimes and languages."

homeContent :: Html
homeContent =
  tabs $ Tabs $ [
    projectsTab,
    servicesTab,
    talksTab,
    interestsTab,
    linksTab
  ]

main :: IO ()
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
page pTitle bodyContent =
  docTypeHtml $ do
    H.head $ do
      H.title (H.toHtml pTitle)
      H.meta ! httpEquiv "X-UA-Compatible" ! content "IE-edge"
      H.meta ! name "viewport" ! content "width=device-width, initial-scale=1"
      css (bootstrapLink "/css/bootstrap.min.css")
      css "style.css"
    H.body $ do
      bodyContent
      js "jquery-1.11.1.min.js"
      js "bootstrap-3.1.1-dist/js/bootstrap.min.js"

