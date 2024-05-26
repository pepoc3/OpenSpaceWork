"use client";

import { configureStore } from "@reduxjs/toolkit";
import pushSlice from "@/redux/slice/pushSlice";

export const store = configureStore({
  reducer: {
    push: pushSlice,
  },

  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: false,
    }),
});
