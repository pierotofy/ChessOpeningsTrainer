<template>
  <v-app>
    
    <BoardTab :active="tab === 'explore'" mode="tree"/>
    <BoardTab :active="tab === 'practice'" mode="treetrain"/>

    <v-bottom-navigation
      v-model="tab"
      color="primary"
      grow>
      <v-btn value="explore" class="nav-btn">
        <span>Explore</span>
        <v-icon>mdi-history</v-icon>
      </v-btn>
      <v-btn value="practice" class="nav-btn">
        <span>Practice</span>
        <v-icon>mdi-history</v-icon>
      </v-btn>
      <v-btn value="list" class="nav-btn">
        <span>List</span>
        <v-icon>mdi-history</v-icon>
      </v-btn>
    </v-bottom-navigation>
  </v-app>
</template>

<script>
import BoardTab from './components/BoardTab';

export default {
  name: 'App',

  components: {
    BoardTab
  },

  data: () => ({
    tab: 'explore'
  }),
};
</script>

<style>
.v-bottom-navigation{
  position: fixed !important;
}
.nav-btn{
 height: 56px !important;
 max-width: none !important;
}
.hide{
  display: none;
}
.tab{
  max-width: none;
  padding: 0;
}
.board{
  margin-top: 60px;
  width: 100%;
  height: 100%;
  height: calc(100vh - 116px);
  border: none;
}
</style>