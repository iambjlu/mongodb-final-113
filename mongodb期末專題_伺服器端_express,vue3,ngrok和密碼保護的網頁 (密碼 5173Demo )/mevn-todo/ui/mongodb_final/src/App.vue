<template>
  <div>
    <!-- 如果密碼正確，則顯示內容 -->
    <div v-if="isPasswordCorrect">
      <h1>📝 待辦事項</h1>
      <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
        <input v-model="newNote" class="mdl-textfield__input" type="text" id="newNote" placeholder="輸入待辦事項">
      </div><br>
      <select v-model="importance">
        <option disabled value="">選擇重要性</option>
        <option value="低">低</option>
        <option value="中">中</option>
        <option value="高">高</option>
      </select>&nbsp;&nbsp;
      <select v-model="urgency">
        <option disabled value="">選擇緊急性</option>
        <option value="低">低</option>
        <option value="中">中</option>
        <option value="高">高</option>
      </select>&nbsp;&nbsp;
      <button class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent" @click="addNewNote">新增待辦事項</button>&nbsp;
      <hr />
      <table class="mdl-data-table mdl-js-data-table mdl-data-table mdl-shadow--2dp" id="">
        <thead>
          <tr>
            <th style="text-align: left;color:#000;font-size: 16px;"><br>
      <button class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" style="color:gray" @click="refreshData">🔄</button>&nbsp;
      <button class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" style="color:gray" @click="isPasswordCorrect = false">🔒</button>
            </th>
            <th style="text-align: left;color:#000;font-size: 16px;">事項</th>
            <th style="text-align: left;color:#000;font-size: 16px;">重要性和緊急程度</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="note in notes" :key="note.id">
            <template v-if="editNoteId === note.id">
              <td style="text-align:center">
                <button class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" style="color:gray" @click="updateNote">完成</button>&nbsp;
                <button class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" style="color:gray" @click="editNoteId = null">取消</button>
              </td>
              <td style="text-align:center">
                <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                  <input class="mdl-textfield__input" type="text" v-model="editNoteDescription" @keydown.esc="editNoteId = null" style="color:#000">
                </div>
              </td>
              <td style="text-align:center;color: #000;">
                <span>重要嗎？</span>&nbsp;&nbsp;
                <select v-model="editNoteImportance">
                  <option disabled value="">選擇重要性</option>
                  <option value="低">低</option>
                  <option value="中">中</option>
                  <option value="高">高</option>
                </select><br>
                <span>緊急嗎？</span>&nbsp;&nbsp;
                <select v-model="editNoteUrgency">
                  <option disabled value="">選擇緊急性</option>
                  <option value="低">低</option>
                  <option value="中">中</option>
                  <option value="高">高</option>
                </select>
              </td>
            </template>
            <template v-else>
              <td style="text-align:center">
                <button class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" style="color:gray" @click="startEditing(note)">編輯</button>&nbsp;
                <button class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" style="color:gray" @click="deleteNote(note.id)">刪除</button>
              </td>
              <td style="text-align: left;font-size: large; color: #000;">
                <b style="text-align: left;font-size: large; color: #000;">{{ note.description }}</b>
              </td>
              <td style="text-align: left; color: #000;">
                {{ note.importance }}<br>
                <p>最後修改：{{ note.lastModified }}</p>
              </td>
            </template>
          </tr>
        </tbody>
      </table><br><br>
    </div>

    <!-- 如果密碼不正確，則顯示密碼輸入框 -->
    <div v-else>
      <h1>🔒 待辦事項</h1>
      <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
        <input class="mdl-textfield__input" type="password" v-model="password" id="password" placeholder="輸入密碼" @keydown.enter="checkPassword">
      </div><br>
      <button class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent" @click="checkPassword">登入</button>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

const API_URL = "https://65c1-59-120-242-188.ngrok-free.app/";

export default {
  name: 'App',
  data() {
    return {
      password: '',
      correctPassword: '5173Demo',
      isPasswordCorrect: false,
      newNote: '',
      importance: '',
      urgency: '',
      notes: [],
      editNoteId: null,
      editNoteDescription: '',
      editNoteImportance: '',
      editNoteUrgency: ''
    }
  },

  methods: {
    async refreshData() {
      axios.get(API_URL + "api/todoapp/GetNote")
        .then((response) => {
          this.notes = response.data;
        });
    },
    async addNewNote() {
      if (!this.newNote.trim() || !this.importance || !this.urgency) {
        alert('所有欄位都必須填寫');
        return;
      }
      const response = await axios.post(`${API_URL}api/todoapp/AddNote`, {
        newNotes: this.newNote,
        importance: this.importance,
        urgency: this.urgency
      });
      this.refreshData();
      this.newNote = '';
      this.importance = '';
      this.urgency = '';
      alert(response.data);
    },
    async deleteNote(id) {
      const response = await axios.delete(`${API_URL}api/todoapp/DeleteNote?id=${id}`);
      this.refreshData();
      alert(response.data);
    },
    startEditing(note) {
      this.editNoteId = note.id;
      this.editNoteDescription = note.description;
      this.editNoteImportance = note.importance;
      this.editNoteUrgency = note.urgency;
    },
    async updateNote() {
      if (!this.editNoteDescription.trim() || !this.editNoteImportance || !this.editNoteUrgency) {
        alert('所有欄位都必須填寫');
        return;
      }
      const response = await axios.put(`${API_URL}api/todoapp/UpdateNote`, {
        id: this.editNoteId,
        newDescription: this.editNoteDescription,
        importance: this.editNoteImportance,
        urgency: this.editNoteUrgency
      });
      this.refreshData();
      this.editNoteId = null;
      this.editNoteDescription = '';
      this.editNoteImportance = '';
      this.editNoteUrgency = '';
      alert(response.data);
    },
    checkPassword() {
      if (this.password === this.correctPassword) {
        this.isPasswordCorrect = true;
        this.password = '';
      } else {
        alert('再試一次');
      }
    }
  },
  mounted() {
    this.refreshData();
  }
}
</script>

<style scoped>
header {
  line-height: 1.5;
  max-height: 100vh;
}

.logo {
  display: block;
  margin: 0 auto 2rem;
}

nav {
  width: 100%;
  font-size: 12px;
  text-align: center;
  margin-top: 2rem;
}

nav a.router-link-exact-active {
  color: var(--color-text);
}

nav a.router-link-exact-active:hover {
  background-color: transparent;
}

nav a {
  display: inline-block;
  padding: 0 1rem;
  border-left: 1px solid var(--color-border);
}

nav a:first-of-type {
  border: 0;
}

@media (min-width: 1024px) {
  header {
    display: flex;
    place-items: center;
    padding-right: calc(var(--section-gap) / 2);
  }

  .logo {
    margin: 0 2rem 0 0;
  }

  header .wrapper {
    display: flex;
    place-items: flex-start;
    flex-wrap: wrap;
  }

  nav {
    text-align: left;
    margin-left: -1rem;
    font-size: 1rem;
    padding: 1rem 0;
    margin-top: 1rem;
  }
}
</style>
