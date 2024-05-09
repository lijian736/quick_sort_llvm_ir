; file name: quick_sort.ll
; quick sort implementation in LLVM ir
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; the original array tips string
@global_original_tips = private unnamed_addr constant [17 x i8] c"Original array:\0A\00", align 1
; the sorted array tips string
@global_sorted_tips = private unnamed_addr constant [15 x i8] c"Sorted array:\0A\00", align 1
; the printf integer format string
@global_integer_format = private unnamed_addr constant [4 x i8] c"%d \00", align 1
; the new line ASCII character
@global_new_line = private unnamed_addr constant [1 x i8] c"\0A", align 1

; external printf function
declare i32 @printf(ptr noundef, ...)

; the global data array which will be sorted, int32 [6, 7, 5, 2, 6, 8, 4, 11, 12, 3]
@global_data_array = private global [10 x i32] [i32 6, i32 7, i32 5, i32 2, i32 6, i32 8, i32 4, i32 11, i32 12, i32 3], align 16

; print the array `global_data_array`
define void @print_array(){
    ; allocate and initialize i to 0
    %i = alloca i32                                     ; int i = ...
    store i32 0, ptr %i                                 ; ..... = 0

    br label %loop_start

    ; start for loop
loop_start:
    %i_value = load i32, ptr %i
    %cmp_result = icmp slt i32 %i_value, 10             ; check if i < 10
    br i1 %cmp_result, label %for_loop, label %loop_end

for_loop:
    ; print the array item
    %item_ptr = getelementptr inbounds [10 x i32], ptr @global_data_array, i64 0, i32 %i_value
    %array_item = load i32, ptr %item_ptr
    call i32 @printf(ptr noundef @global_integer_format, i32 noundef %array_item)

    ; increment the i
    %i_value_1 = add i32 %i_value, 1                      ; ... = i + 1
    store i32 %i_value_1, ptr %i                          ;   i = ...

    br label %loop_start

loop_end:
    call i32 @printf(ptr noundef @global_new_line)
    ret void
}

; swap the items in global_data_array, the items index are index_0 and index_1
define void @swap(i32 %index_0, i32 %index_1){
    %tmp_0_ptr = getelementptr inbounds [10 x i32], ptr @global_data_array, i64 0, i32 %index_0
    %tmp_1_ptr = getelementptr inbounds [10 x i32], ptr @global_data_array, i64 0, i32 %index_1
    
    %tmp_0 = load i32, ptr %tmp_0_ptr
    %tmp_1 = load i32, ptr %tmp_1_ptr
    store i32 %tmp_0, ptr %tmp_1_ptr
    store i32 %tmp_1, ptr %tmp_0_ptr

    ret void
}

; partition the global array with the range [low, high]
; return i32: the partition pivot location
define i32 @partition(i32 %low, i32 %high){
    ; initialize pivot to be the first element
    %pivot_ptr = getelementptr inbounds [10 x i32], ptr @global_data_array, i64 0, i32 %low
    %pivot = load i32, ptr %pivot_ptr


    %i = alloca i32
    %j = alloca i32

    ; initialize i,j to low and high
    store i32 %low, ptr %i
    store i32 %high, ptr %j

    br label %start_label

start_label:
    ; compare i value and j value
    %i_value = load i32, ptr %i
    %j_value = load i32, ptr %j
    %cmp_i_j = icmp slt i32 %i_value, %j_value

    br i1 %cmp_i_j, label %while_label, label %end_label

while_label:
    ; find the first element greater than the pivot (from start)

    ; while(global_data_array[i] <= pivot && i < high)
    %i_1 = load i32, ptr %i
    %i_value_ptr = getelementptr inbounds [10 x i32], ptr @global_data_array, i64 0, i32 %i_1
    ; global_data_array[i]
    %arr_i_value = load i32, ptr %i_value_ptr
    ; global_data_array[i] <= pivot
    %l_val_pivot_cmp_result = icmp sle i32 %arr_i_value, %pivot
    ; i < high
    %i_high_cmp_result = icmp slt i32 %i_1, %high
    %both_cmp_result = and i1 %l_val_pivot_cmp_result, %i_high_cmp_result
    br i1 %both_cmp_result, label %i_incr, label %right_smaller

i_incr:
    ; i++
    %i_2 = add i32 %i_1, 1
    store i32 %i_2, ptr %i
    br label %while_label

right_smaller:
    ; find the first element smaller than the pivot (from last)

    ; while(global_data_array[j] > pivot && j > low)
    %j_1 = load i32, ptr %j
    %j_value_ptr = getelementptr inbounds [10 x i32], ptr @global_data_array, i64 0, i32 %j_1
    ; global_data_array[j]
    %arr_j_value = load i32, ptr %j_value_ptr
    ; global_data_array[j] > pivot
    %r_val_pivot_cmp_result = icmp sgt i32 %arr_j_value, %pivot
    ; j > low
    %j_low_cmp_result = icmp sgt i32 %j_1, %low
    %both_cmp_result_1 = and i1 %r_val_pivot_cmp_result, %j_low_cmp_result
    br i1 %both_cmp_result_1, label %j_decr, label %swap_i_j

j_decr:
    ;j--
    %j_2 = sub i32 %j_1, 1
    store i32 %j_2, ptr %j
    br label %right_smaller

swap_i_j:
    %i_3 = load i32, ptr %i
    %j_3 = load i32, ptr %j
    %i_j_cmp = icmp slt i32 %i_3, %j_3
    
    br i1 %i_j_cmp, label %swap_i_j_val, label %start_label

swap_i_j_val:
    %i_4 = load i32, ptr %i
    %j_4 = load i32, ptr %j
    call void @swap(i32 %i_4, i32 %j_4)
    br label %start_label

end_label:
    %j_5 = load i32, ptr %j
    call void @swap(i32 %low, i32 %j_5)

    ret i32 %j_5
}

; quick sort, low: low index, high: high index
define void @quick_sort(i32 %low, i32 %high){
    %cmp_result = icmp slt i32 %low, %high        ; if low < high
    
    br i1 %cmp_result, label %quick_sort_label, label %end_label
    
quick_sort_label:
    %partition_idx = call i32 @partition(i32 %low, i32 %high)
    %partition_minus_1 = sub i32 %partition_idx, 1
    %partition_add_1 = add i32 %partition_idx, 1

    ; recursively call @quick_sort for left and right half base on partition index
    call void @quick_sort(i32 %low, i32 %partition_minus_1)
    call void @quick_sort(i32 %partition_add_1, i32 %high)
    br label %end_label

end_label:
    ret void
}

; the main entry of this program
define dso_local i32 @main() {
    ; print the tips before sorting the array
    call i32 @printf(ptr noundef @global_original_tips)
    call void @print_array()

    ; quick sort
    call void @quick_sort(i32 0, i32 9)

    ; print the tips after sorting the array
    call i32 @printf(ptr noundef @global_sorted_tips)
    call void @print_array()
    ret i32 0
}