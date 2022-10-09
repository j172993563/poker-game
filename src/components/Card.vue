<template>
  <div
    class="card-box"
    :class="{
      finish: isFinish,
      'not-click': !isClick,
      skill: isClick && isSkill,
    }"
    @click="$emit('click')"
    :style="{
      transition: `${animationTime}ms left ease-in-out, ${animationTime}ms top ease-in-out`,
      color,
      top: top + 'px',
      left: left + 'px',
      zIndex,
    }"
  >
    <span>{{ value }}</span>
  </div>
</template>

<script>
export default {
  name: "Card",
  emits: ["click"],
  props: {
    value: String,
    type: String,
    color: String,
    isSkill: Boolean,
    animationTime: Number,
  },
  data() {
    return {
      top: 0,
      left: 0,
      isClick: false,
      zIndex: 0,
      isFinish: false,
    };
  },
};
</script>
<style scoped>
.card-box {
  width: 50px;
  height: 60px;
  background-color: white;
  border-radius: 5px;
  border: 1px solid #333;
  display: inline-flex;
  justify-content: center;
  align-items: center;
  font-weight: 600;
  font-size: 20px;
  margin: 1px;
  position: absolute;
  user-select: none;
}

.not-click {
  background: lightblue;
}
.not-click > span {
  display: none;
}
.not-click:hover {
  background-color: #eee;
  cursor: pointer;
}

.finish {
  display: none !important;
}

.skill:hover {
  background-color: yellow !important;
  cursor: pointer !important;
}
</style>
