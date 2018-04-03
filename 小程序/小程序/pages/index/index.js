Page({
  data: {
    //上一次点击的时间
    lastTapTime: 0,

    //内容
    message: 'Hello MINA!',

    //组件属性
    id: 0,

    //控制属性
    condition: true,

    //三元运算
    flag: false,

    //算数运算
    a: 1,
    b: 2,
    c: 3,

    //逻辑判断
    length: 6,

    //字符串运算
    name: 'MINA',

    //数组组合
    zero: 0,

    //对象
    x: 0,
    y: 1,

    //对象展开
    obj1: {
      a: 1,
      b: 2
    },
    obj2: {
      c: 3,
      d: 4
    },
    e: 5,

    //对象key和value相同
    foo: 'my-foo',
    bar: 'my-bar'
  },
  changeText: function () {
    this.setData({
      message: 'changed data'
    })
  },
// 模拟双击效果
  binddoubletap: function (e) {
    //获取点击当前时间
    var curTime = e.timeStamp
    //上一次点击的时间
    var lastTime = this.data.lastTapTime
    if (lastTime > 0) {
      //电脑双击事件间隔为300ms以内，这里也用300ms间隔吧
      if (curTime - lastTime < 300) {
        console.log("双击事件触发")
      } else {
        console.log("单击事件触发")
      }
    } else {
      console.log("单击事件触发")
    }
    //保存本次点击的时间
    this.setData({
      lastTapTime: curTime
    })
  }

})