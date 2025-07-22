return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.10.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 16,
  height = 16,
  tilewidth = 8,
  tileheight = 8,
  nextlayerid = 7,
  nextobjectid = 6,
  properties = {},
  tilesets = {
    {
      name = "Stone",
      firstgid = 1,
      class = "",
      tilewidth = 8,
      tileheight = 8,
      spacing = 0,
      margin = 0,
      columns = 15,
      image = "../images/tiles/NewStoneAutoGameJam.png",
      imagewidth = 120,
      imageheight = 48,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 8,
        height = 8
      },
      properties = {},
      wangsets = {},
      tilecount = 90,
      tiles = {}
    },
    {
      name = "Dirt",
      firstgid = 91,
      class = "",
      tilewidth = 8,
      tileheight = 8,
      spacing = 0,
      margin = 0,
      columns = 15,
      image = "../images/tiles/NewDirtAutoGameJam.png",
      imagewidth = 120,
      imageheight = 48,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 8,
        height = 8
      },
      properties = {},
      wangsets = {},
      tilecount = 90,
      tiles = {}
    }
  },
  layers = {
    {
      type = "imagelayer",
      image = "../images/InertiaCavernBackgroundGameJam.png",
      id = 5,
      name = "Background",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = -88,
      offsety = -64,
      parallaxx = 1,
      parallaxy = 1,
      repeatx = false,
      repeaty = false,
      properties = {}
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 16,
      height = 16,
      id = 1,
      name = "Platform",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 10, 11, 12, 13, 14, 11, 102, 103, 104, 15, 0, 0, 0,
        0, 0, 0, 25, 26, 27, 28, 29, 26, 27, 28, 29, 30, 0, 0, 0,
        0, 0, 0, 40, 41, 43, 43, 44, 41, 42, 43, 44, 45, 0, 0, 0,
        0, 0, 0, 55, 41, 41, 41, 41, 41, 42, 43, 44, 60, 0, 0, 0,
        0, 0, 0, 25, 41, 42, 43, 44, 41, 42, 43, 44, 30, 0, 0, 0,
        0, 0, 0, 40, 41, 42, 43, 44, 41, 42, 43, 44, 45, 0, 0, 0,
        0, 0, 0, 55, 56, 57, 58, 59, 56, 57, 58, 59, 60, 0, 0, 0,
        0, 0, 0, 70, 71, 72, 73, 74, 71, 72, 73, 74, 75, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 54, 0, 0
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 4,
      name = "Ground",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 2,
          name = "",
          type = "",
          shape = "rectangle",
          x = 24,
          y = 32,
          width = 80,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 6,
      name = "Lookies",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 4,
          name = "",
          type = "",
          shape = "rectangle",
          x = 72,
          y = 32,
          width = 24,
          height = 8,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
