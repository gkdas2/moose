mu=1
rho=1
advected_interp_method='average'
velocity_interp_method='rc'

[GlobalParams]
  rhie_chow_user_object = 'rc'
  advected_interp_method = ${advected_interp_method}
  velocity_interp_method = ${velocity_interp_method}
[]

[UserObjects]
  [rc]
    type = INSFVRhieChowInterpolator
    u = u
    v = v
    pressure = pressure
  []
[]

[Mesh]
  inactive = 'mesh internal_boundary_bot internal_boundary_top'
  [mesh]
    type = CartesianMeshGenerator
    dim = 2
    dx = '1'
    dy = '1 1 1'
    ix = '5'
    iy = '5 5 5'
    subdomain_id = '1
                    2
                    3'
  []
  [internal_boundary_bot]
    type = SideSetsBetweenSubdomainsGenerator
    input = mesh
    new_boundary = 'internal_bot'
    primary_block = 1
    paired_block = 2
  []
  [internal_boundary_top]
    type = SideSetsBetweenSubdomainsGenerator
    input = internal_boundary_bot
    new_boundary = 'internal_top'
    primary_block = 2
    paired_block = 3
  []
  [diverging_mesh]
    type = FileMeshGenerator
    file = 'expansion_quad.e'
  []
[]

[Variables]
  [u]
    type = INSFVVelocityVariable
    initial_condition = 0
  []
  [v]
    type = INSFVVelocityVariable
    initial_condition = 1
  []
  [pressure]
    type = INSFVPressureVariable
  []
  [temperature]
    type = INSFVEnergyVariable
  []
[]

[AuxVariables]
  [advected_density]
    type = MooseVariableFVReal
    initial_condition = ${rho}
  []
[]

[FVKernels]
  [mass]
    type = INSFVMassAdvection
    variable = pressure
    rho = ${rho}
  []

  [u_advection]
    type = INSFVMomentumAdvection
    variable = u
    rho = ${rho}
    momentum_component = 'x'
  []
  [u_viscosity]
    type = INSFVMomentumDiffusion
    variable = u
    mu = ${mu}
    force_boundary_execution = true
    momentum_component = 'x'
  []
  [u_pressure]
    type = INSFVMomentumPressure
    variable = u
    momentum_component = 'x'
    pressure = pressure
  []

  [v_advection]
    type = INSFVMomentumAdvection
    variable = v
    rho = ${rho}
    momentum_component = 'y'
  []
  [v_viscosity]
    type = INSFVMomentumDiffusion
    variable = v
    mu = ${mu}
    force_boundary_execution = true
    momentum_component = 'y'
  []
  [v_pressure]
    type = INSFVMomentumPressure
    variable = v
    momentum_component = 'y'
    pressure = pressure
  []

  [temp_advection]
    type = INSFVEnergyAdvection
    variable = temperature
    advected_interp_method = 'upwind'
  []
  [temp_source]
    type = FVBodyForce
    variable = temperature
    function = 10
    block = 1
  []
[]

[FVBCs]
  inactive = 'noslip-u noslip-v'
  [inlet-u]
    type = INSFVInletVelocityBC
    boundary = 'bottom'
    variable = u
    function = 0
  []
  [inlet-v]
    type = INSFVInletVelocityBC
    boundary = 'bottom'
    variable = v
    function = 1
  []
  [noslip-u]
    type = INSFVNoSlipWallBC
    boundary = 'right'
    variable = u
    function = 0
  []
  [noslip-v]
    type = INSFVNoSlipWallBC
    boundary = 'right'
    variable = v
    function = 0
  []
  [free-slip-u]
    type = INSFVNaturalFreeSlipBC
    boundary = 'right'
    variable = u
    momentum_component = 'x'
  []
  [free-slip-v]
    type = INSFVNaturalFreeSlipBC
    boundary = 'right'
    variable = v
    momentum_component = 'y'
  []
  [axis-u]
    type = INSFVSymmetryVelocityBC
    boundary = 'left'
    variable = u
    u = u
    v = v
    mu = ${mu}
    momentum_component = x
  []
  [axis-v]
    type = INSFVSymmetryVelocityBC
    boundary = 'left'
    variable = v
    u = u
    v = v
    mu = ${mu}
    momentum_component = y
  []
  [axis-p]
    type = INSFVSymmetryPressureBC
    boundary = 'left'
    variable = pressure
  []
  [outlet_p]
    type = INSFVOutletPressureBC
    boundary = 'top'
    variable = pressure
    function = 0
  []
  [inlet_temp]
    type = FVNeumannBC
    boundary = 'bottom'
    variable = temperature
    value = 300
  []
[]

[Materials]
  [ins_fv]
    type = INSFVEnthalpyFunctorMaterial
    temperature = 'temperature'
    rho = ${rho}
  []
  [advected_material_property]
    type = ADGenericFunctorMaterial
    prop_names = 'advected_rho cp'
    prop_values ='${rho} 1'
  []
[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_pc_type -sub_pc_factor_shift_type'
  petsc_options_value = 'asm      200                lu           NONZERO'
  line_search = 'none'
  nl_rel_tol = 1e-12
[]

[Postprocessors]
  [inlet_mass_variable]
    type = VolumetricFlowRate
    boundary = bottom
    vel_x = u
    vel_y = v
    advected_quantity = advected_density
  []
  [inlet_mass_constant]
    type = VolumetricFlowRate
    boundary = bottom
    vel_x = u
    vel_y = v
    advected_quantity = ${rho}
  []
  [inlet_mass_matprop]
    type = VolumetricFlowRate
    boundary = bottom
    vel_x = u
    vel_y = v
    advected_quantity = 'advected_rho'
  []
  [mid1_mass]
    type = VolumetricFlowRate
    boundary = internal_bot
    vel_x = u
    vel_y = v
    advected_quantity = ${rho}
  []
  [mid2_mass]
    type = VolumetricFlowRate
    boundary = internal_top
    vel_x = u
    vel_y = v
    advected_quantity = ${rho}
  []
  [outlet_mass]
    type = VolumetricFlowRate
    boundary = top
    vel_x = u
    vel_y = v
    advected_quantity = ${rho}
  []

  [inlet_momentum_x]
    type = VolumetricFlowRate
    boundary = bottom
    vel_x = u
    vel_y = v
    advected_quantity = u
  []

  [inlet_momentum_y]
    type = VolumetricFlowRate
    boundary = bottom
    vel_x = u
    vel_y = v
    advected_quantity = v
  []

  [mid1_advected_energy]
    type = VolumetricFlowRate
    boundary = internal_bot
    vel_x = u
    vel_y = v
    advected_quantity = 'rho_cp_temp'
    advected_interp_method = 'upwind'
  []
  [mid2_advected_energy]
    type = VolumetricFlowRate
    boundary = internal_top
    vel_x = u
    vel_y = v
    advected_quantity = 'rho_cp_temp'
    advected_interp_method = 'upwind'
  []
  [outlet_advected_energy]
    type = VolumetricFlowRate
    boundary = top
    vel_x = u
    vel_y = v
    advected_quantity = 'rho_cp_temp'
    advected_interp_method = 'upwind'
  []
[]

[Outputs]
  csv = true
[]
