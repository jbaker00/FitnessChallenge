import { firebaseConfig } from "./config.js";
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.14.0/firebase-app.js";
import {
  getAuth,
  signInWithPopup,
  signOut,
  GoogleAuthProvider,
  onAuthStateChanged,
} from "https://www.gstatic.com/firebasejs/10.14.0/firebase-auth.js";
import {
  getFirestore,
  collection,
  doc,
  getDoc,
  addDoc,
  setDoc,
  deleteDoc,
  onSnapshot,
  orderBy,
  query,
} from "https://www.gstatic.com/firebasejs/10.14.0/firebase-firestore.js";

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// ── DOM refs ──────────────────────────────────────────────────────────────────
const authScreen        = document.getElementById("auth-screen");
const appScreen         = document.getElementById("app-screen");
const signInBtn         = document.getElementById("sign-in-btn");
const signOutBtn        = document.getElementById("sign-out-btn");
const authError         = document.getElementById("auth-error");
const addBtn            = document.getElementById("add-btn");
const itemList          = document.getElementById("item-list");
const filterTabs        = document.getElementById("filter-tabs");
const modalOverlay      = document.getElementById("modal-overlay");
const modalTitle        = document.getElementById("modal-title");
const modalCloseBtn     = document.getElementById("modal-close-btn");
const itemForm          = document.getElementById("item-form");
const formDocId         = document.getElementById("form-doc-id");
const formChallengeType = document.getElementById("form-challenge-type");
const formDayNumber     = document.getElementById("form-day-number");
const formTitle         = document.getElementById("form-title");
const formDifficulty    = document.getElementById("form-difficulty");
const formDuration      = document.getElementById("form-duration");
const formCalories      = document.getElementById("form-calories");
const formWorkoutTitle  = document.getElementById("form-workout-title");
const formWorkoutDesc   = document.getElementById("form-workout-description");
const formNutritionTip  = document.getElementById("form-nutrition-tip");
const formHabitGoal     = document.getElementById("form-habit-goal");
const formMotivQuote    = document.getElementById("form-motivational-quote");
const exercisesContainer = document.getElementById("exercises-container");
const addExerciseBtn    = document.getElementById("add-exercise-btn");
const formError         = document.getElementById("form-error");
const formCancelBtn     = document.getElementById("form-cancel-btn");

// ── State ─────────────────────────────────────────────────────────────────────
let unsubscribe = null;
let allItems    = [];
let activeFilter = "all";

// ── Auth ──────────────────────────────────────────────────────────────────────
onAuthStateChanged(auth, async (user) => {
  if (user) {
    const allowed = await checkAdminAllowlist(user.email);
    if (allowed) {
      showApp();
      startListener();
    } else {
      showError(authError, `Access denied. ${user.email} is not an authorized admin.`);
      await signOut(auth);
    }
  } else {
    showAuth();
    stopListener();
  }
});

signInBtn.addEventListener("click", async () => {
  hideError(authError);
  const provider = new GoogleAuthProvider();
  try {
    await signInWithPopup(auth, provider);
  } catch (err) {
    showError(authError, err.message);
  }
});

signOutBtn.addEventListener("click", () => signOut(auth));

async function checkAdminAllowlist(email) {
  const ref = doc(db, "admins", email);
  const snap = await getDoc(ref);
  return snap.exists();
}

// ── Screen helpers ────────────────────────────────────────────────────────────
function showApp() {
  authScreen.classList.add("hidden");
  appScreen.classList.remove("hidden");
}

function showAuth() {
  appScreen.classList.add("hidden");
  authScreen.classList.remove("hidden");
}

// ── Firestore listener ────────────────────────────────────────────────────────
function startListener() {
  // Order by challengeType then dayNumber
  const q = query(
    collection(db, "fitness_challenges"),
    orderBy("challengeType", "asc"),
    orderBy("dayNumber", "asc")
  );
  unsubscribe = onSnapshot(q, (snapshot) => {
    allItems = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }));
    applyFilterAndRender();
  }, (err) => {
    console.error("Snapshot error:", err);
  });
}

function stopListener() {
  if (unsubscribe) { unsubscribe(); unsubscribe = null; }
}

// ── Filter Tabs ───────────────────────────────────────────────────────────────
filterTabs.addEventListener("click", (e) => {
  const tab = e.target.closest(".filter-tab");
  if (!tab) return;
  document.querySelectorAll(".filter-tab").forEach(t => t.classList.remove("active"));
  tab.classList.add("active");
  activeFilter = tab.dataset.filter;
  applyFilterAndRender();
});

function applyFilterAndRender() {
  const filtered = activeFilter === "all"
    ? allItems
    : allItems.filter(item => item.challengeType === activeFilter);
  renderItems(filtered);
}

// ── Helpers ───────────────────────────────────────────────────────────────────
const DIFFICULTY_COLORS = {
  Beginner:     { bg: "#d4f8e8", text: "#0a6640" },
  Intermediate: { bg: "#fff3cd", text: "#856404" },
  Advanced:     { bg: "#ffe0e0", text: "#c0392b" },
};

function diffBadge(diff) {
  if (!diff) return "";
  const c = DIFFICULTY_COLORS[diff] || { bg: "#e0e0e0", text: "#555" };
  return `<span class="badge" style="background:${c.bg};color:${c.text}">${escHtml(diff)}</span>`;
}

function typeBadge(type) {
  if (!type) return "";
  const is7 = type === "7day";
  return `<span class="type-badge ${is7 ? "type-7" : "type-30"}">${is7 ? "7 DAY" : "30 DAY"}</span>`;
}

// ── Render ────────────────────────────────────────────────────────────────────
function renderItems(items) {
  if (items.length === 0) {
    itemList.innerHTML = `<div class="empty-state">No challenges found. Click <strong>+ Add Challenge</strong> to get started.</div>`;
    return;
  }

  itemList.innerHTML = items.map((c) => {
    const exerciseCount = Array.isArray(c.exercises) ? c.exercises.length : 0;
    return `
    <div class="item-card">
      <div class="item-body">
        <div class="item-top-row">
          ${typeBadge(c.challengeType)}
          <span class="day-num">Day ${c.dayNumber != null ? escHtml(String(c.dayNumber)) : "—"}</span>
          ${diffBadge(c.difficulty)}
        </div>
        <h3>${escHtml(c.title || "")}</h3>
        ${c.workoutTitle ? `<p class="workout-title">🏋️ ${escHtml(c.workoutTitle)}</p>` : ""}
        <div class="stats-row">
          ${c.durationMinutes != null ? `<span class="stat">⏱ ${c.durationMinutes} min</span>` : ""}
          ${c.caloriesBurn != null ? `<span class="stat">🔥 ${Number(c.caloriesBurn).toLocaleString()} cal</span>` : ""}
          ${exerciseCount > 0 ? `<span class="stat">💪 ${exerciseCount} exercise${exerciseCount !== 1 ? "s" : ""}</span>` : ""}
        </div>
        ${c.motivationalQuote ? `<p class="quote">"${escHtml(c.motivationalQuote)}"</p>` : ""}
      </div>
      <div class="item-actions">
        <button class="btn btn-sm btn-ghost" onclick="editItem(${escHtml(JSON.stringify(c.id))})">Edit</button>
        <button class="btn btn-sm btn-danger" onclick="deleteItem(${escHtml(JSON.stringify(c.id))}, ${escHtml(JSON.stringify(c.title || 'Day ' + c.dayNumber))})">Delete</button>
      </div>
    </div>`;
  }).join("");
}

function escHtml(str) {
  if (str == null) return "";
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

// ── Exercise rows ─────────────────────────────────────────────────────────────
addExerciseBtn.addEventListener("click", () => addExerciseRow({}));

function addExerciseRow(ex) {
  const idx = exercisesContainer.querySelectorAll(".exercise-row").length;
  const row = document.createElement("div");
  row.className = "exercise-row";
  row.innerHTML = `
    <div class="exercise-row-header">
      <span class="exercise-index">Exercise ${idx + 1}</span>
      <button type="button" class="btn-remove-exercise" aria-label="Remove">✕</button>
    </div>
    <div class="exercise-fields">
      <div class="form-group">
        <label>Name</label>
        <input type="text" class="ex-name" placeholder="e.g. Push-ups" value="${escHtml(ex.name || "")}" />
      </div>
      <div class="form-group">
        <label>Sets</label>
        <input type="number" class="ex-sets" placeholder="3" min="0" value="${ex.sets != null ? ex.sets : ""}" />
      </div>
      <div class="form-group">
        <label>Reps</label>
        <input type="number" class="ex-reps" placeholder="12" min="0" value="${ex.reps != null ? ex.reps : ""}" />
      </div>
      <div class="form-group">
        <label>Duration (sec)</label>
        <input type="number" class="ex-duration" placeholder="0" min="0" value="${ex.durationSeconds != null ? ex.durationSeconds : ""}" />
      </div>
      <div class="form-group ex-notes-group">
        <label>Notes</label>
        <input type="text" class="ex-notes" placeholder="Optional notes" value="${escHtml(ex.notes || "")}" />
      </div>
    </div>`;

  row.querySelector(".btn-remove-exercise").addEventListener("click", () => {
    row.remove();
    reindexExerciseRows();
  });

  exercisesContainer.appendChild(row);
}

function reindexExerciseRows() {
  exercisesContainer.querySelectorAll(".exercise-row").forEach((row, i) => {
    const label = row.querySelector(".exercise-index");
    if (label) label.textContent = `Exercise ${i + 1}`;
  });
}

function getExercises() {
  return Array.from(exercisesContainer.querySelectorAll(".exercise-row")).map((row) => ({
    name:            row.querySelector(".ex-name").value.trim(),
    sets:            row.querySelector(".ex-sets").value !== "" ? Number(row.querySelector(".ex-sets").value) : null,
    reps:            row.querySelector(".ex-reps").value !== "" ? Number(row.querySelector(".ex-reps").value) : null,
    durationSeconds: row.querySelector(".ex-duration").value !== "" ? Number(row.querySelector(".ex-duration").value) : null,
    notes:           row.querySelector(".ex-notes").value.trim(),
  })).filter(ex => ex.name !== "");
}

function clearExercises() {
  exercisesContainer.innerHTML = "";
}

function loadExercises(exercises) {
  clearExercises();
  if (Array.isArray(exercises)) {
    exercises.forEach(ex => addExerciseRow(ex));
  }
}

// ── Modal ─────────────────────────────────────────────────────────────────────
addBtn.addEventListener("click", () => openModal(null));
modalCloseBtn.addEventListener("click", closeModal);
formCancelBtn.addEventListener("click", closeModal);
modalOverlay.addEventListener("click", (e) => { if (e.target === modalOverlay) closeModal(); });

function openModal(item) {
  formDocId.value           = item?.id ?? "";
  formChallengeType.value   = item?.challengeType ?? "";
  formDayNumber.value       = item?.dayNumber ?? "";
  formTitle.value           = item?.title ?? "";
  formDifficulty.value      = item?.difficulty ?? "";
  formDuration.value        = item?.durationMinutes ?? "";
  formCalories.value        = item?.caloriesBurn ?? "";
  formWorkoutTitle.value    = item?.workoutTitle ?? "";
  formWorkoutDesc.value     = item?.workoutDescription ?? "";
  formNutritionTip.value    = item?.nutritionTip ?? "";
  formHabitGoal.value       = item?.habitGoal ?? "";
  formMotivQuote.value      = item?.motivationalQuote ?? "";
  loadExercises(item?.exercises || []);
  modalTitle.textContent = item
    ? `Edit: ${item.challengeType === "7day" ? "7 Day" : "30 Day"} – Day ${item.dayNumber}`
    : "New Challenge";
  hideError(formError);
  modalOverlay.classList.remove("hidden");
  formTitle.focus();
}

function closeModal() {
  modalOverlay.classList.add("hidden");
  itemForm.reset();
  clearExercises();
}

// ── CRUD ──────────────────────────────────────────────────────────────────────
itemForm.addEventListener("submit", async (e) => {
  e.preventDefault();
  hideError(formError);

  const data = {
    challengeType:       formChallengeType.value,
    dayNumber:           formDayNumber.value !== "" ? Number(formDayNumber.value) : null,
    title:               formTitle.value.trim(),
    difficulty:          formDifficulty.value,
    durationMinutes:     formDuration.value !== "" ? Number(formDuration.value) : null,
    caloriesBurn:        formCalories.value !== "" ? Number(formCalories.value) : null,
    workoutTitle:        formWorkoutTitle.value.trim(),
    workoutDescription:  formWorkoutDesc.value.trim(),
    exercises:           getExercises(),
    nutritionTip:        formNutritionTip.value.trim(),
    habitGoal:           formHabitGoal.value.trim(),
    motivationalQuote:   formMotivQuote.value.trim(),
  };

  try {
    const id = formDocId.value;
    if (id) {
      await setDoc(doc(db, "fitness_challenges", id), data);
    } else {
      await addDoc(collection(db, "fitness_challenges"), data);
    }
    closeModal();
  } catch (err) {
    showError(formError, err.message);
  }
});

window.editItem = async (id) => {
  const snap = await getDoc(doc(db, "fitness_challenges", id));
  if (snap.exists()) openModal({ id: snap.id, ...snap.data() });
};

window.deleteItem = async (id, name) => {
  if (!confirm(`Delete "${name}"? This cannot be undone.`)) return;
  try {
    await deleteDoc(doc(db, "fitness_challenges", id));
  } catch (err) {
    alert("Error deleting: " + err.message);
  }
};

// ── Error helpers ─────────────────────────────────────────────────────────────
function showError(el, msg) { el.textContent = msg; el.classList.remove("hidden"); }
function hideError(el)      { el.textContent = ""; el.classList.add("hidden"); }
