import React from "react";
import ReactDOM from "react-dom/client";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import { App } from "./pages/App";
import { Dashboard } from "./pages/Dashboard";
import { Trips } from "./pages/Trips";
import { Users } from "./pages/Users";
import { Payments } from "./pages/Payments";
import { Drivers } from "./pages/Drivers";
import { Bookings } from "./pages/Bookings";
import { DriverDetail } from "./pages/DriverDetail";

const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
    children: [
      { path: "/", element: <Dashboard /> },
      { path: "/trips", element: <Trips /> },
      { path: "/users", element: <Users /> },
      { path: "/payments", element: <Payments /> },
      { path: "/drivers", element: <Drivers /> },
      { path: "/drivers/:id", element: <DriverDetail /> },
      { path: "/bookings", element: <Bookings /> },
    ],
  },
]);

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
);
