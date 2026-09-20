<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('tbl_rolePermission', function (Blueprint $table) {
            $table->bigIncrements('v_rolePermissionId');

            $table->unsignedBigInteger('v_roleId');
            $table->unsignedBigInteger('v_permissionId');

            $table->dateTime('v_createdAt')->useCurrent();

            $table->unique(
                ['v_roleId', 'v_permissionId'],
                'uq_rolePermission_pair'
            );

            $table->foreign('v_roleId', 'fk_rolePermission_role')
                ->references('v_roleId')
                ->on('tbl_role')
                ->onUpdate('cascade')
                ->onDelete('cascade');

            $table->foreign('v_permissionId', 'fk_rolePermission_permission')
                ->references('v_permissionId')
                ->on('tbl_permission')
                ->onUpdate('cascade')
                ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tbl_rolePermission');
    }
};