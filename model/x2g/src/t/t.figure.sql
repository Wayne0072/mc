T_b("--path:");
T_b(widget->path);
T_b("\n");
T_b("INSERT INTO GD_GE VALUES (");
T_b(T_s(widget->ID));
T_b(", ");
T_b(T_s(diagram->ID));
T_b(", ");
T_b(T_s(widget->ooaofooa_ID));
T_b(", ");
T_b(T_s(widget->OOA_Type));
T_b(", 0, '");
T_b(widget->path);
T_b("');");
T_b("\n");
T_b("INSERT INTO GD_SHP VALUES (");
T_b(T_s(widget->ID));
T_b(");");
T_b("\n");
T_b("INSERT INTO GD_NCS VALUES (");
T_b(T_s(widget->ID));
T_b(");");
T_b("\n");
T_b("INSERT INTO DIM_ND VALUES (");
T_b("\n");
T_b("	");
T_b("160.000000, -- width");
T_b("\n");
T_b("	");
T_b("80.000000, -- height");
T_b("\n");
T_b("	");
T_b(T_s(widget->ID));
T_b(");");
T_b("\n");
T_b("INSERT INTO DIM_GE VALUES (");
T_b("\n");
T_b("	");
T_b(T_s(widget->x));
T_b(".000000, -- X");
T_b("\n");
T_b("	");
T_b(T_s(widget->y));
T_b(".000000, -- Y");
T_b("\n");
T_b("	");
T_b(T_s(widget->ID));
T_b(", 0);");
T_b("\n");
T_b("INSERT INTO DIM_ELE VALUES (");
T_b(T_s(widget->ID));
T_b(", 0, 0);");
T_b("\n");
