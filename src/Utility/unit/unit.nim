import math

type
  Year* = distinct float64
  Week* = distinct float64
  Day* = distinct float64
  Hour* = distinct float64
  Minute* = distinct float64
  Second* = distinct float64
  MiliSecond* = distinct float64
  MicroSecond* = distinct float64
  NanoSecond* = distinct float64 
  
  TimeUnit* = tuple[year: Year, week: Week, day: Day, hour: Hour, 
  minute: Minute, second: Second, milisecond: MiliSecond, 
  microsecond: MicroSecond, nanosecond: NanoSecond]

  TimeConcept* = concept x
    x is Year or x is Week or x is Day or x is Hour or x is Minute or 
    x is Second or x is MiliSecond or x is MicroSecond or x is NanoSecond 

  Degrees* = distinct float64
  Radian* = distinct float64
  Gradian* = distinct float64
  AngleMinute* = distinct float64
  AngleSecond* = distinct float64

  AngleUnit* = tuple[degrees: Degrees, radian: Radian, gradian: Gradian, 
  angleMinute: AngleMinute, angleSecond: AngleSecond]

  AngleConcept* = concept x
    x is Degrees or x is Radian or x is Gradian or x is AngleMinute or 
    x is AngleSecond

  KiloMeter* = distinct float64
  Meter* = distinct float64
  CentiMeter* = distinct float64
  MiliMeter* = distinct float64
  MicroMeter* = distinct float64
  NanoMeter* = distinct float64
  Thou* = distinct float64
  Point* = distinct float64
  Pica* = distinct float64
  Inch* = distinct float64
  Feet* = distinct float64
  Yard* = distinct float64
  Link* = distinct float64
  Rod* = distinct float64
  Chain* = distinct float64
  Furlong* = distinct float64
  Mile* = distinct float64
  Nmile* = distinct float64
  League* = distinct float64
  寸* = distinct float64
  尺* = distinct float64
  間* = distinct float64
  町* = distinct float64
  里* = distinct float64

  LengthUnit* = tuple[kilometer: KiloMeter, meter: Meter, 
  centimeter: CentiMeter, milimeter: MiliMeter, micrometer: MicroMeter, 
  nanometer: NanoMeter, thou: Thou, point: Point, pica: Pica, inch: Inch,
  feet: Feet, yard: Yard, link: Link, rod: Rod, chain: Chain, 
  furlong: Furlong, mile: Mile, nmail: Nmile, league: League, 
  寸: 寸, 尺: 尺, 間: 間, 町: 町, 里: 里]

  LengthConcept* = concept x
    x is KiloMeter or x is Meter or x is CentiMeter or x is MiliMeter or
    x is MicroMeter or x is NanoMeter or x is Thou or x is Point or
    x is Pica or x is Inch or x is Feet or x is Yard or x is Link or
    x is Rod or x is Chain or x is Furlong or x is Mile or x is Nmile or
    x is League

  Parsec* = distinct float64
  LightYear* = distinct float64
  Au* = distinct float64

  AstraUnit* = tuple[parsec: Parsec, lightyear: LightYear, au: Au]

  AstraConcept* = concept x
    x is Parsec or x is LightYear or x is Au

  SquareKiloMeter* = distinct float64
  SquareMeter* = distinct float64
  SquareCentiMeter* = distinct float64
  SquareMiliMeter* = distinct float64
  SquareMile* = distinct float64
  SquareFurlong* = distinct float64
  SquareChain* = distinct float64
  SquareRod* = distinct float64
  SquareLink* = distinct float64
  SquareYard* = distinct float64
  SquareFeet* = distinct float64
  SquareInch* = distinct float64
  SquarePica* = distinct float64
  SquarePoint* = distinct float64
  SquareThou* = distinct float64
  Acre* = distinct float64
  Hectare* = distinct float64
  坪* = distinct float64
  畝* = distinct float64
  段步* = distinct float64
  町步* = distinct float64

  SurfaceUnit* = tuple[squarekilometer: SquareKiloMeter, squaremeter: SquareMeter,
  squareCentiMeter: SquareCentiMeter, squareMiliMeter: SquareMiliMeter, 
  squaremile: SquareMile, squarefurlong: SquareFurlong, squarechain: SquareChain,
  squarerod: SquareRod, squarelink: SquareLink, squareyard: SquareYard, 
  squarefeet: SquareFeet, squareinch: SquareInch, squarepica: SquarePica, 
  squarepoint: SquarePoint, squarethou: SquareThou, acre: Acre, hectare: Hectare, 
  坪: 坪, 畝: 畝, 段步: 段步, 町步: 町步]

  SurfaceConcept* = concept x
    x is SquareKiloMeter or x is SquareMeter or x is SquareCentiMeter or 
    x is SquareMiliMeter or x is SquareMile or x is SquareFurlong or
    x is SquareChain or x is SquareRod or x is SquareLink or x is SquareYard or
    x is SquareFeet or x is SquareInch or x is SquarePica or x is SquarePoint or
    x is SquareThou or x is Acre or x is Hectare or x is 坪 or x is 畝 or
    x is 段步 or x is 町步

  CubeMeter* = distinct float64
  CubeCentiMeter* = distinct float64
  CubeMiliMeter* = distinct float64
  CubeFurlong* = distinct float64
  CubeChain* = distinct float64
  CubeRod* = distinct float64
  CubeLink* = distinct float64
  CubeYard* = distinct float64
  CubeFeet* = distinct float64
  CubeInch* = distinct float64
  Gallon* = distinct float64
  Barrel* = distinct float64
  Liter* = distinct float64
  MiliLiter* = distinct float64
  合* = distinct float64
  升* = distinct float64
  斗* = distinct float64
  石* = distinct float64

  VolumeUnit* = tuple[cubemeter: CubeMeter, cubecentimeter: CubeCentiMeter, 
  cubemilimeter: CubeMiliMeter, cubefurlong: CubeFurlong, cubechain: CubeChain,
  cuberod: CubeRod, cubelink: CubeLink, cubeyard: CubeYard, cubefeet: CubeFeet,
  cubeinch: CubeInch, gallon: Gallon, barrel: Barrel, litter: Liter, mililiter: MiliLiter,
  合: 合, 升: 升, 斗: 斗, 石: 石]

  VolumeConcept* = concept x
    x is CubeMeter or x is CubeCentiMeter or x is CubeMiliMeter or x is CubeFurlong or
    x is CubeChain or x is CubeRod or x is CubeLink or x is CubeYard or x is CubeFeet or
    x is CubeInch or x is Gallon or x is Barrel or x is Liter or x is MiliLiter or
    x is 合 or x is 升 or x is 斗 or x is 石

  KiloGram* = distinct float64
  Gram* = distinct float64
  MiliGram* = distinct float64
  MicroGram* = distinct float64
  Grain* = distinct float64
  Ounce* = distinct float64
  Pound* = distinct float64
  錢* = distinct float64
  兩* = distinct float64
  斤* = distinct float64
  貫* = distinct float64
  Carat* = distinct float64
  Ton* = distinct float64

  MassUnit* = tuple[kilogram: KiloGram, gram: Gram, miligram: MiliGram, microgram: MicroGram, 
  grain: Grain, ounce: Ounce, pound: Pound, 錢: 錢, 兩: 兩, 斤: 斤, 貫: 貫, carat: Carat, ton: Ton]

  MassConcept* = concept x
    x is KiloGram or x is Gram or x is MiliGram or x is MicroGram or x is Grain or x is Ounce or
    x is Pound or x is 錢 or x is 錢 or x is 兩 or x is 兩 or x is 斤 or x is 斤 or x is 貫 or x is 貫 or
    x is Carat or x is Ton

  GigaNewton* = distinct float64
  MegaNewton* = distinct float64
  KiloNewton* = distinct float64
  Newton* = distinct float64
  MiliNewton* = distinct float64
  MicroNewton* = distinct float64
  Dyne* = distinct float64

  ForceUnit* = tuple[giganewton: GigaNewton, meganewton: MegaNewton, kilonewton: KiloNewton, newton: Newton, milinewton: MiliNewton, 
  micronewton: MicroNewton, dyne: Dyne]

  ForceConcept* = concept x
    x is MegaNewton or x is GigaNewton or x is KiloNewton or x is Newton or 
    x is MiliNewton or x is MicroNewton or x is Dyne

  GigaWatt* = distinct float64
  MegaWatt* = distinct float64
  KiloWatt* = distinct float64
  Watt* = distinct float64
  MiliWatt* = distinct float64
  HorsePower* = distinct float64
  
  PowerUnit* = tuple[gigawatt: GigaWatt, megawatt: MegaWatt, 
  kilowatt: KiloWatt, watt: Watt, miliwatt: MiliWatt, horsepower: HorsePower]

  PowerConcept* = concept x
    x is GigaWatt or x is MegaWatt or x is KiloWatt or 
    x is Watt or x is MiliWatt or x is HorsePower

  GigaHertz* = distinct float64
  MegaHertz* = distinct float64
  KiloHertz* = distinct float64
  Hertz* = distinct float64
  MiliHertz* = distinct float64

  FrequencyUnit* = tuple[gigahertz: GigaHertz, megahertz: MegaHertz, kilohertz: KiloHertz,
  hertz: Hertz, milihertz: MiliHertz]

  FrequencyConcept* = concept x
    x is GigaHertz or x is MegaHertz or x is KiloHertz or x is Hertz or x is MiliHertz

  GigaAmpere* = distinct float64
  MegaAmpere* = distinct float64
  KiloAmpere* = distinct float64
  Ampere* = distinct float64
  MiliAmpere* = distinct float64
  MicroAmpere* = distinct float64
  NanoAmpere* = distinct float64

  CurrentUnit* = tuple[
    gigaampere: GigaAmpere,
    megaampere: MegaAmpere,
    kiloampere: KiloAmpere,
    ampere: Ampere,
    miliampere: MiliAmpere,
    microampere: MicroAmpere,
    nanoampere: NanoAmpere
  ]

  CurrentConcept* = concept x
    x is GigaAmpere or x is MegaAmpere or x is KiloAmpere or
    x is Ampere or x is MiliAmpere or x is MicroAmpere or x is NanoAmpere

  GigaCoulomb* = distinct float64
  MegaCoulomb* = distinct float64
  KiloCoulomb* = distinct float64
  Coulomb* = distinct float64
  MiliCoulomb* = distinct float64
  MicroCoulomb* = distinct float64
  NanoCoulomb* = distinct float64

  ChargeUnit* = tuple[
    gigacoulomb: GigaCoulomb,
    megacoulomb: MegaCoulomb,
    kilocoulomb: KiloCoulomb,
    coulomb: Coulomb,
    milicoulomb: MiliCoulomb,
    microcoulomb: MicroCoulomb,
    nanocoulomb: NanoCoulomb
  ]
  
  ChargeConcept* = concept x
    x is GigaCoulomb or x is MegaCoulomb or x is KiloCoulomb or
    x is Coulomb or x is MiliCoulomb or x is MicroCoulomb or x is NanoCoulomb

  GigaOhm* = distinct float64
  MegaOhm* = distinct float64
  KiloOhm* = distinct float64
  Ohm* = distinct float64
  MiliOhm* = distinct float64
  MicroOhm* = distinct float64
  NanoOhm* = distinct float64

  ResistanceUnit* = tuple[
    gigaohm: GigaOhm,
    megaohm: MegaOhm,
    kiloohm: KiloOhm,
    ohm: Ohm,
    miliohm: MiliOhm,
    microohm: MicroOhm,
    nanoohm: NanoOhm
  ]

  ResistanceConcept* = concept x
    x is GigaOhm or x is MegaOhm or x is KiloOhm or
    x is Ohm or x is MiliOhm or x is MicroOhm or x is NanoOhm

  GigaSiemens* = distinct float64
  MegaSiemens* = distinct float64
  KiloSiemens* = distinct float64
  Siemens* = distinct float64
  MiliSiemens* = distinct float64
  MicroSiemens* = distinct float64
  NanoSiemens* = distinct float64



  GigaVolt* = distinct float64
  MegaVolt* = distinct float64
  KiloVolt* = distinct float64
  Volt* = distinct float64
  MiliVolt* = distinct float64
  MicroVolt* = distinct float64
  NanoVolt* = distinct float64

  KiloHenry* = distinct float64
  Henry* = distinct float64
  MiliHenry* = distinct float64
  MicroHenry* = distinct float64
  NanoHenry* = distinct float64

  KiloFarad* = distinct float64
  MiliFarad* = distinct float64
  MicroFarad* = distinct float64
  NanoFarad* = distinct float64

  KiloWeber* = distinct float64
  Weber* = distinct float64
  MiliWeber* = distinct float64
  MicroWeber* = distinct float64
  NanoWeber* = distinct float64

  KiloTesla* = distinct float64
  Tesla* = distinct float64
  MiliTesla* = distinct float64
  MicroTesla* = distinct float64
  NanoTesla* = distinct float64

const 
  TimeConverter*: TimeUnit = (
    year: Year(1 * 60 * 60 * 24 * 365),
    week: Week(1 * 60 * 60 * 24 * 7),
    day: Day(1 * 60 * 60 * 24),
    hour: Hour(1 * 60 * 60),
    minute: Minute(1 * 60),
    second: Second(1),
    milisecond: MiliSecond((1) / 1000),
    microsecond: MicroSecond(1 / (1000 * 1000)),
    nanosecond: NanoSecond(1 / (1000 * 1000 * 1000))
  )

  AngleConverter*: AngleUnit = (
    degrees: Degrees(1.0),
    radian: Radian(PI / 180.0),
    gradian: Gradian(10.0 / 9.0),
    angleMinute: AngleMinute(60.0),
    angleSecond: AngleSecond(3600.0)
  )

  LengthConverter*: LengthUnit = (
    kilometer: KiloMeter(1000.0),
    meter: Meter(1.0),
    centimeter: CentiMeter(0.01),
    milimeter: MiliMeter(0.001),
    micrometer: MicroMeter(1e-6),
    nanometer: NanoMeter(1e-9),
    thou: Thou(0.0000254),
    point: Point(0.000352778),
    pica: Pica(0.00423333),
    inch: Inch(0.0254),
    feet: Feet(0.3048),
    yard: Yard(0.9144),
    link: Link(0.201168),
    rod: Rod(5.0292),
    chain: Chain(20.1168),
    furlong: Furlong(201.168),
    mile: Mile(1609.344),
    nmail: Nmile(1852.0),
    league: League(4828.032),
    寸: 寸(0.030303),
    尺: 尺(0.30303),
    間: 間(1.81818),
    町: 町(109.09),
    里: 里(3927.27)
  )

  AstraLengthConverter*: AstraUnit = (
    parsec: Parsec(3.261587474),
    lightyear: LightYear(1.0),
    au: Au(0.000015813)
  )

  SurfaceUnitConverter*: SurfaceUnit = (
    squarekilometer: SquareKiloMeter(1_000_000.0),
    squaremeter: SquareMeter(1.0),
    squareCentiMeter: SquareCentiMeter(0.0001),
    squareMiliMeter: SquareMiliMeter(0.000001),
    squaremile: SquareMile(2_589_988.11),
    squarefurlong: SquareFurlong(40_468.564224),
    squarechain: SquareChain(404.68564224),
    squarerod: SquareRod(25.29285264),
    squarelink: SquareLink(0.040468564224),
    squareyard: SquareYard(0.83612736),
    squarefeet: SquareFeet(0.09290304),
    squareinch: SquareInch(0.00064516),
    squarepica: SquarePica(0.00000064516 * 12 * 6),
    squarepoint: SquarePoint(0.00000064516 * 12),
    squarethou: SquareThou(0.00000000064516),
    acre: Acre(4046.8564224),
    hectare: Hectare(10_000.0),
    坪: 坪(3.305785),
    畝: 畝(99.17355),
    段步: 段步(330.5785),
    町步: 町步(991.7355)
  )

  VolumeConverter*: VolumeUnit = (
    cubemeter: CubeMeter(1.0),
    cubecentimeter: CubeCentiMeter(0.000001),
    cubemilimeter: CubeMiliMeter(0.000000001),
    cubefurlong: CubeFurlong(81321629.974),
    cubechain: CubeChain(7744.0),
    cuberod: CubeRod(127.296),
    cubelink: CubeLink(0.008261),
    cubeyard: CubeYard(0.764554857984),
    cubefeet: CubeFeet(0.028316846592),
    cubeinch: CubeInch(0.000016387064),
    gallon: Gallon(0.003785411784),
    barrel: Barrel(0.158987294928),
    litter: Liter(0.001),
    mililiter: MiliLiter(0.000001),
    合: 合(0.00018),
    升: 升(0.0018),
    斗: 斗(0.018),
    石: 石(0.18)
  )

  