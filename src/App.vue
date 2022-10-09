<template>
  <div style="min-width: 1260px">
    <div class="main">
      <div class="score-bord">
        <p>规则：{{ rules.vanishCount }}张相同的牌即可消除。</p>
        <p>
          用时：{{ rules.timeStr }}秒，剩余：【{{
            cardDatas.leaveList.length
          }}张牌】
        </p>
      </div>
      <div class="operator">
        <button @click="init">重新洗牌</button>
        <button @click="handleRandomClick">随机选择</button>
        <button v-show="!isRandom" @click="handleAllRandomClick">
          随机全择
        </button>
        <button v-show="isRandom" @click="isRandom = false">停止全择</button>
        <button
          v-show="!isUsingSkill"
          :disabled="rules.skill <= 0"
          @click="handleUseSkill"
        >
          立马消除点数相同的牌（{{ rules.skill }}次）
        </button>
        <button v-show="isUsingSkill" @click="isUsingSkill = false">
          取消使用技能
        </button>
      </div>
      <div class="cards" ref="cards">
        <Card
          v-for="cardInfo in cardDatas.cards"
          :key="cardInfo.key"
          :value="cardInfo.value"
          :type="cardInfo.type"
          :ref="'card' + cardInfo.key"
          :color="cardInfo.color"
          :isSkill="isUsingSkill"
          :animationTime="animationTime"
          @click="handleCardClick(cardInfo)"
        />
      </div>
    </div>
    <div class="slot">
      <Slot ref="slot" />
    </div>
  </div>
</template>

<script>
import Card from "./components/Card.vue";
import Slot from "./components/Slot.vue";

function getAllCards() {
  let key = 0;
  const cardType = [
    "A",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "J",
    "Q",
    "K",
  ];
  const shapes = ["♠", "♥", "♣", "♦"];
  const allCards = [];
  for (let i = 0; i < cardType.length; i++) {
    const num = cardType[i];
    const newType = shapes.map((shape, j) => ({
      value: shape + num,
      type: num,
      color: j % 2 ? "red" : "black",
      key: key++,
    }));
    allCards.push(...newType);
  }

  return allCards;
}

let count = {
  timer: null,
};

export default {
  name: "App",
  components: {
    Card,
    Slot,
  },
  data() {
    return {
      cardDatas: {
        insertSlotList: [],
        leaveList: [],
        cards: getAllCards(),
      },
      rules: {
        // 多少张牌就可以消除
        vanishCount: 4,
        timeStr: 0,
        // 技能的使用次数
        skill: 3,
      },
      isAnimation: false,
      isRandom: false,
      isUsingSkill: false,
      cardsBox: {
        top: 0,
        left: 0,
      },
    };
  },
  computed: {
    // 动画的时长
    animationTime() {
      return this.isRandom ? 200 : 500;
    },
    slot() {
      return this.$refs.slot;
    },
    isWin() {
      return (
        this.cardDatas.insertSlotList.length === 0 &&
        this.cardDatas.leaveList.length === 0
      );
    },
    isLose() {
      return this.slot.currentIndex >= this.slot.cardCount;
    },
    isFinish() {
      return this.isWin || this.isLose;
    },
  },
  mounted() {
    this.setCardsBoxTop();
    this.setInstanceToCard();
    this.init();
  },
  methods: {
    setCardsBoxTop() {
      this.cardsBox.top = this.$refs.cards.offsetTop;
      this.cardsBox.left = this.$refs.cards.offsetLeft;
    },
    handleAllRandomClick() {
      this.isRandom = true;
      this.allRandom();
    },
    allRandom() {
      const leave = this.slot.cardCount - this.slot.currentIndex;
      if (leave <= 1 || this.isFinish) return (this.isRandom = false);
      this.handleRandomClick();
      setTimeout(() => {
        // 如果不是正在随机，则不再执行
        if (this.isRandom) {
          this.allRandom();
        }
      }, 200 + this.animationTime);
    },
    handleRandomClick() {
      // 已经结束游戏就直接退出
      if (this.isFinish) return;
      // 取消使用技能
      this.isUsingSkill = false;
      const { leaveList } = this.cardDatas;
      // 随机一个数字
      const currentIndex = Math.floor(Math.random() * leaveList.length);
      const currentCard = leaveList[currentIndex];
      // 判断是否已经被点击或者不存在，是则再次运行
      if (!currentCard || (currentCard && currentCard.inst.isClick)) {
        this.handleRandomClick();
      } else {
        this.handleCardClick(currentCard);
      }
    },
    usingSkill(cardInfo) {
      const cardInstance = cardInfo.inst;
      // 只能选已经被翻开过的牌
      if (!cardInstance.isClick) return alert("请选择已被翻开过的牌！");
      // 遍历剩余卡片数组和已入卡槽数组，找出相同数点的牌，将牌isFinish状态设为true
      this.cardDatas.cards
        .filter((c) => c.type === cardInfo.type)
        .forEach((c) => {
          c.inst.isFinish = true;
          this.removeLeaveList(c);
          this.removeInsertSlotList(c);
        });
      this.rules.skill--;
      this.isUsingSkill = false;
      this.reSort();
    },
    removeLeaveList(cardInfo) {
      this.cardDatas.leaveList = this.cardDatas.leaveList.filter(
        (c) => c !== cardInfo
      );
    },
    removeInsertSlotList(cardInfo) {
      this.cardDatas.insertSlotList = this.cardDatas.insertSlotList.filter(
        (c) => c !== cardInfo
      );
    },
    handleCardClick(cardInfo) {
      // 如果正在动画或者已经结束，立即退出
      if (this.isAnimation || this.isFinish) return;
      // 如果是使用技能模式
      if (this.isUsingSkill) return this.usingSkill(cardInfo);
      // 非技能模式
      const cardInstance = cardInfo.inst;
      // 已经被点击过的牌立即退出
      if (cardInstance.isClick) return;
      // 正做动画
      this.isAnimation = true;
      this.moveCardIntoSlot(cardInstance, this.slot.currentIndex++);
      cardInstance.isClick = true;
      // 维护插槽数组
      this.cardDatas.insertSlotList.push(cardInfo);
      // 维护现有在场数组
      this.cardDatas.leaveList = this.cardDatas.leaveList.filter(
        (c) => c !== cardInfo
      );
      // 做完动画，将开关设回
      setTimeout(() => {
        this.checkVanish();
        this.reSort();
        this.checkRet();
        this.isAnimation = false;
      }, 200 + this.animationTime);
    },
    moveCardIntoSlot(cardInstance, slotIndex) {
      const currentPosition = this.slot.cardPosition[slotIndex];
      cardInstance.left = currentPosition.left - this.cardsBox.left;
      cardInstance.top = currentPosition.top - this.cardsBox.top;
    },
    checkRet() {
      if (this.isFinish) {
        const isContinued = confirm(
          (this.isLose ? "输掉" : "赢得") + "游戏，是否重新开始？"
        );
        if (isContinued) {
          this.init();
        }
      }
    },
    reSort() {
      const notFinishList = (this.cardDatas.insertSlotList =
        this.cardDatas.insertSlotList.filter(
          (card) => !card.inst.isFinish
        )).sort((a, b) => a.key - b.key);
      this.slot.currentIndex = notFinishList.length;
      notFinishList.forEach((card, index) => {
        this.moveCardIntoSlot(card.inst, index);
      });
    },
    checkVanish() {
      const isClickList = this.cardDatas.insertSlotList;
      const cardsSlot = {};
      isClickList.forEach((card) => {
        const key = card.type;
        if (cardsSlot[key]) {
          cardsSlot[key]++;
        } else {
          cardsSlot[key] = 1;
        }
      });

      // 检查哪些是已经集齐了的
      for (const type in cardsSlot) {
        if (Object.hasOwnProperty.call(cardsSlot, type)) {
          const count = cardsSlot[type];
          if (count >= this.rules.vanishCount) {
            // 已经集齐
            isClickList
              .filter((card) => card.type === type)
              .forEach((card) => (card.inst.isFinish = true));
            cardsSlot[type] = 0;
          }
        }
      }
    },
    setInstanceToCard() {
      // 当卡片初始化后，还没有洗牌前，将实例绑定到inst属性上
      for (let i = 0; i < this.cardDatas.cards.length; i++) {
        const cardInstance = this.$refs["card" + i][0];
        const element = this.cardDatas.cards[i];
        element.inst = cardInstance;
      }
    },
    init() {
      // 初始化开关
      this.isAnimation = false;
      this.isRandom = false;
      this.rules.skill = 4;
      // 取消使用技能
      this.isUsingSkill = false;
      // 初始化牌
      this.initCard();
      // 初始化插槽
      this.initSlot();
      // 开始计时
      this.startCountTime();
    },
    startCountTime() {
      if (count.timer != null) {
        clearInterval(count.timer);
        this.rules.timeStr = 0;
      }
      count.timer = setInterval(() => {
        if (this.isFinish) {
          clearInterval(count.timer);
        } else {
          this.rules.timeStr++;
        }
      }, 1000);
    },
    washCard() {
      const total = this.cardDatas.cards.length;
      for (let i = 0; i < total; i++) {
        // 随机抽一数字
        const currentIndex = Math.ceil(Math.random() * total);
        const element = this.cardDatas.cards[i];
        // 将当前牌从数组中删除再插入
        this.cardDatas.cards.splice(i, 1);
        this.cardDatas.cards.splice(currentIndex, 0, element);
      }
    },
    initCard() {
      this.washCard();
      // 初始化在场牌列表
      this.cardDatas.insertSlotList = [];
      this.cardDatas.leaveList = [];
      for (let i = 0; i < this.cardDatas.cards.length; i++) {
        const cardInfo = this.cardDatas.cards[i];
        const card = cardInfo.inst;
        card.zIndex = i;
        card.left = i * 25 + 10;
        card.top = 10;
        card.isClick = false;
        card.isFinish = false;
        // 将排好序的版重新插回数组
        this.cardDatas.leaveList.push(cardInfo);
      }
    },
    initSlot() {
      // 将指针置0
      this.slot.currentIndex = 0;
    },
    handleUseSkill() {
      if (this.rules.skill <= 0) return;
      if (this.isRandom) {
        return alert("正在随机中，请先停止全择！");
      }
      this.isUsingSkill = true;
    },
  },
};
</script>
<style>
.main {
  height: calc(100vh - 84px);
  padding: 10px;
  box-sizing: border-box;
}

.main > *:not(:last-child) {
  margin-bottom: 20px;
}

.operator > button {
  padding: 5px;
  margin: 0 5px;
}

.cards {
  position: relative;
}
</style>
