<template>
  <authenticator>
    <template v-slot="{ user, signOut }">
      <main>
        <header>
          <h2>Video Convert</h2>
          <nav class="nav">
            <ul class="list">
            </ul>
          </nav>
          <button @click="signOut" class="contact">Sign out</button>
        </header>
        <section>
          <router-view :username="user.username" />
        </section>
      </main>
    </template>
  </authenticator>
</template>

<style>
@import '@/assets/base.css';
</style>
