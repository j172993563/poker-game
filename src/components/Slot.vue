<template>
  <div class="slot-box-outer">
    <div class="slot-box-inner">
      <div
        v-for="count in cardCount"
        :key="count"
        class="shadow-card"
        :ref="'shadow' + count"
      ></div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      cardCount: 20,
      cardPosition: [],
      currentIndex: 0,
    };
  },
  mounted() {
    this.setCardPosition();
  },
  methods: {
    setCardPosition() {
      for (let i = 0; i < this.cardCount; i++) {
        const dom = this.$refs["shadow" + (i + 1)][0];
        const top = dom.offsetTop - 1;
        const left = dom.offsetLeft - 1;
        this.cardPosition.push({ top, left });
      }
    },
  },
};
</script>
<style>
.slot-box-outer {
  padding: 5px;
  box-sizing: border-box;
  background-color: brown;
}
.slot-box-outer,
.slot-box-inner {
  border: 1px solid #333;
}
.slot-box-inner {
  padding: 2px;
  width: 100vw;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
}
.shadow-card {
  width: 50px;
  height: 60px;
  border-radius: 5px;
  border: 1px dotted #fff;
  margin: 5px;
}
</style>
