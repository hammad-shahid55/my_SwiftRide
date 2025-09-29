import React from "react";
import ReactDOM from "react-dom/client";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import { App } from "./pages/App";
import { Dashboard } from "./pages/Dashboard";
import { Trips } from "./pages/Trips";
import { Users } from "./pages/Users";
import { Payments } from "./pages/Payments";

const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
    children: [
      { path: "/", element: <Dashboard /> },
      { path: "/trips", element: <Trips /> },
      { path: "/users", element: <Users /> },
      { path: "/payments", element: <Payments /> },
    ],
  },
]);

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
);
