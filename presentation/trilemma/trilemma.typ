#import "@preview/touying:0.4.1": *
#import "@preview/fletcher:0.4.5" as fletcher: diagram, node, edge

#import "university.typ"

#import fletcher.shapes: ellipse
#set page(width: auto, height: auto, margin: 5mm, fill: white)
#set text(font: "Liberation Sans")
#set align(center)



#let s = university.register(aspect-ratio: "16-9", lang: "en")
#let s = (s.methods.info)(
  self: s,
  title: [Solving Vitalik's Trilemma with zk-driven DA and Storage],
  author: [Igor Gulamov],
  institution: [ZeroPool],
)
#let (init, slides, touying-outline, alert, speaker-note) = utils.methods(s)
#show: init

#show strong: alert

#let (slide, empty-slide, title-slide, focus-slide, matrix-slide) = utils.slides(s)
#show: slides



== Vitalik's trilemma

#v(20pt)

#diagram(
  spacing: 40pt,
  cell-size: (8mm, 10mm),
  edge-stroke: 1pt,
  edge-corner-radius: 5pt,
  mark-scale: 70%,


  node((0,0), text("Scalability", fill: white, weight: "bold"), fill: blue.darken(45%), shape: ellipse,  width: 230pt, height: 80pt),
  node((1,0), text("Security", fill: white, weight: "bold"), fill: blue.darken(45%), shape: ellipse,  width: 230pt, height: 80pt),
  node((2,0), text("Decentralization", fill: white, weight: "bold"), fill: blue.darken(45%), shape: ellipse,  width: 230pt, height: 80pt),
)

#pause
#v(40pt)

Select two of the three

#image("../../assets/cat1.svg", height: 160pt)

== Why do we need to solve the trilemma?

#v(40pt)
#align(left)[
- Mass adoption: scalability and decentralization, keeping the security

- Transition from Web2 to Web3
]

#place(bottom+right, dx:-30pt, image("../../assets/cat2.svg", height: 300pt))

== Historical approaches to solve the trilemma

#v(60pt)

Multichain Ecosystem

Plasma 

Optimistic Rollup

ZK Rollup

ZK Validium

Data Availability Layer


== Why rollups are not enough?

#pause

Rollups scale the computation but do not scale the data

#pause 

#image("../../assets/data_floats_up.svg", width: 35%)

Data floats up to the L1

#pause
#place(top+left, dx:145pt, dy:200pt, text(size:1.5em, fill: blue.darken(60%), weight: "bold", "We need recursive rollups"))


== Storage-centric approach
#align(left)[
Long-term storage solutions:


- Filecoin

- Arweave

- Ethstorage
]

#pause
#place(bottom+right, dy:-40pt, align(left, [
Improvements to be implemented:


- RS codes for data sharding
- whole-chain provable zk proof
]))

== RS codes

#slide(repeat:4, self => [
  #let (uncover, only, alternatives) = utils.methods(self)
  
  #alternatives[
    #image("../../assets/rs1.png", height:280pt)
  ][
    #image("../../assets/rs2.png", height:280pt)
  ][
    #image("../../assets/rs3.png", height:280pt)
  ][
    #image("../../assets/rs1.png", height:280pt)
  ]
],[
  #v(20pt)
  $circle.stroked.tiny$ Encode the data as the polynomial
  #pause

  $circle.stroked.tiny$ Blowup the data
  #pause

  $circle.stroked.tiny$ Forget part of the data
  #pause

  $circle.stroked.tiny$ Recover the source data

  $circle.stroked.tiny$ RS codes are $tilde 10$ times more efficient, than replication, with better security guarantees.
  

])

== RS codes and SNARKs

Commitment to RS encoded shard could be easily proved and verified in SNARK with the following polynomial equation:

$ F(x, x^M) - F(x, y_0) = (x^M - y_0) dot Q(x), $

where F(x,y) is a bivariate polynomial, representing the source data

$ F(g^i, h^j) = "data"_(M j + i),$

and $F(x, y_0)$ is a polynomial, representing the encoded data of the shard.

== zk-driven data-centric rollup

#slide(self => [
#image("../../assets/rollup-zkda.svg", width: 340pt)
],[

$circle.stroked.tiny$ DA and Storage contract could be proved and verified in zkSNARK
#pause

$circle.stroked.tiny$ The proof could be merged with the rollup proof
#pause

$circle.stroked.tiny$ Full proof of both state transition and data availability

$circle.stroked.tiny$ The rollup does not require any data stored outside of it

])

== Some parameters of data-centric rollup

#table(
columns: (auto, auto),
inset: 6pt,
stroke: 0.7pt,
align: horizon,
[Storage cost], [~ 0.15 USD per 1 GB per year #super[1]],
[Soundness], [110 bits #super[2]],
[Capacity], [>1 PB]
)
#v(1.5em) // vertical space
#super[1] based on the Hetzner storage node, less for optimized rigs

#super[2] the probability of forgetting any chunk of data is less than $2^(-110)$ if half of the network is honest

#pause

#v(20pt)

#text(size:1.5em, fill: blue.darken(60%), weight: "bold", "Rollups recursion: unlocked")

== Could we reach more scalability?

#slide(repeat:2, self => [
  #let (uncover, only, alternatives) = utils.methods(self)
  #alternatives[
   #align(center)[
    #image("../../assets/cat4.svg", width: 250pt)
   ]
  ][#align(center)[
Yes
#image("../../assets/architecture.svg", width: 540pt)
  ]]
])

== Thank you for your attention!


#grid(columns: 2, gutter:20pt,
[
#image("../../assets/article-sharded-storage-1.svg", width: 200pt)

#link("https://zeropool.network/research/blockchain-sharded-storage-web2-costs-and-web3-security-with-shamir-secret-sharing")[Blockchain Sharded Storage: Web2 Costs and Web3 Security with Shamir Secret Sharing]
], [
#image("../../assets/article-sharded-storage-2.svg", width: 200pt)

#link("https://zeropool.network/research/minimal-fully-recursive-zkda-rollup-with-sharded-storage")[Minimal fully recursive zkDA rollup with sharded storage]
], [
])
