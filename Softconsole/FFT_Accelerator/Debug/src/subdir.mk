################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/ARP_protocol.c \
../src/FFT_apb.c \
../src/GMII_Filter_Trap.c \
../src/ICMP_protocol.c \
../src/MAC_Filter.c \
../src/VSC8541_01_phy.c \
../src/main.c 

OBJS += \
./src/ARP_protocol.o \
./src/FFT_apb.o \
./src/GMII_Filter_Trap.o \
./src/ICMP_protocol.o \
./src/MAC_Filter.o \
./src/VSC8541_01_phy.o \
./src/main.o 

C_DEPS += \
./src/ARP_protocol.d \
./src/FFT_apb.d \
./src/GMII_Filter_Trap.d \
./src/ICMP_protocol.d \
./src/MAC_Filter.d \
./src/VSC8541_01_phy.d \
./src/main.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GNU ARM Cross C Compiler'
	arm-none-eabi-gcc -mcpu=cortex-m3 -mthumb -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g3 -I../firmware/hal/CortexM3/GNU/ -std=gnu11 -specs=cmsis.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


